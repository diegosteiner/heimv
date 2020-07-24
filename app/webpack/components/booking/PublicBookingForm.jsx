import React from "react";
import { useForm, Controller } from "react-hook-form";
import { Form, Button, Card } from "react-bootstrap";
import CalendarControl from "../calendar/CalendarControl";
import { useTranslation } from 'react-i18next';

const PublicBookingForm = ({ booking, homes }) => {
  const { t, i18n } = useTranslation()
  const { register, handleSubmit, errors, control, getValues } = useForm()
  const onSubmit = (data) => {
    console.log(data)
  }

  return (
    <Card>
      <Card.Body>
        <Form noValidate onSubmit={handleSubmit(onSubmit)}>
          <Form.Group>
            <Form.Label>{t('activerecord.attributes.booking.home')}</Form.Label>
            <Form.Control name="home_id" ref={register} as="select" defaultValue={booking.home_id}>
              {Array.from(homes).map(home => <option key={home.id} value={home.id}>{home.name}</option>)}
            </Form.Control>
          </Form.Group>

          <Form.Group>
            <Form.Label className="required">{t('activerecord.attributes.occupancy.begins_at')}</Form.Label>
            <Controller as={<CalendarControl></CalendarControl>} isInvalid={!!errors.begins_at} name="begins_at" control={control} rules={{ required: true }}></Controller>
            <Form.Control.Feedback type="invalid">Zomg</Form.Control.Feedback>
          </Form.Group>

          <Form.Group>
            <Form.Label>Test</Form.Label>
            <Controller as={<CalendarControl></CalendarControl>} isInvalid={!!errors.ends_at} name="ends_at" control={control} rules={{ required: true }}></Controller>
            <Form.Control.Feedback type="invalid">Zomg</Form.Control.Feedback>
          </Form.Group>

          <Form.Group>
            <Form.Label>{t('activerecord.attributes.tenant.email')}</Form.Label>
            <Form.Control required type="email" isInvalid={!!errors.email} name="email" ref={register({ required: true })}></Form.Control>
            <Form.Control.Feedback type="invalid">
              {"E-Mail is required"}
            </Form.Control.Feedback>
          </Form.Group>

          <Form.Group>
            <Form.Label>{t('activerecord.attributes.booking.tenant_organisation')}</Form.Label>
            <Form.Control name="tenant_organisation" ref={register()}></Form.Control>
          </Form.Group>

          <Form.Group>
            <Form.Check type="checkbox">
              <Form.Check.Label>
                <Form.Check.Input type="checkbox" isInvalid={!!errors.xx} name="xx" ref={register({ required: true })}></Form.Check.Input>
                {t('public.bookings.new.accept_conditions_html')}
              </Form.Check.Label>
              <Form.Control.Feedback type="invalid">
                {"E-Mail is required"}
              </Form.Control.Feedback>
            </Form.Check>

          </Form.Group>


          <Button type="submit">Submit</Button>
        </Form>
      </Card.Body>
    </Card>
  )
}

export default PublicBookingForm