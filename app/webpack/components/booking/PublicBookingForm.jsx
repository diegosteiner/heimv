import React from "react";
import { useForm, Controller } from "react-hook-form";
import { Form, Button, Col } from "react-bootstrap";
import CalendarControl from "../calendar/CalendarInput";

const PublicBookingForm = ({ booking, homes }) => {
  const { register, handleSubmit, errors, control } = useForm()
  const onSubmit = (data) => {
    console.log(data)
  }

  return (
    <Form noValidate onSubmit={handleSubmit(onSubmit)}>
      <Form.Group>
        <Form.Label>Test</Form.Label>
        <Form.Control name="home_id" ref={register} as="select" defaultValue={booking.home_id}>
          {Array.from(homes).map(home => <option key={home.id} value={home.id}>{home.name}</option>)}
        </Form.Control>
      </Form.Group>

      <Form.Row>
        <Form.Group md="auto" as={Col}>
          <Form.Label>Test</Form.Label>
          <Controller as={<CalendarControl></CalendarControl>} isInvalid={errors.begins_at} name="begins_at" control={control} rules={{ required: true }}></Controller>
          <Form.Control.Feedback type="invalid">Zomg</Form.Control.Feedback>
        </Form.Group>

        <Form.Group md="auto" as={Col}>
        </Form.Group>
      </Form.Row>

      <Form.Group>
        <Form.Label>E-Mail</Form.Label>
        <Form.Control required type="email" isInvalid={errors.email} name="email" ref={register({ required: true })}></Form.Control>
        <Form.Control.Feedback type="invalid">
          {"E-Mail is required"}
        </Form.Control.Feedback>
      </Form.Group>

      <Button type="submit">Submit</Button>
    </Form>
  )
}

export default PublicBookingForm