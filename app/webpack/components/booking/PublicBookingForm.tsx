import * as React from "react";
import { useForm, Controller } from "react-hook-form";
import { Card, Form, Button } from "react-bootstrap";
import { CalendarControl } from "../calendar/CalendarInput";
import { Trans, useTranslation } from "react-i18next";
import { parseISO, isValid as isValidDate, compareAsc } from "date-fns/esm";

export default function PublicBookingForm({ booking, organisation }) {
  const { t } = useTranslation();
  const { register, handleSubmit, errors, control, getValues } = useForm({
    mode: "onChange",
  });
  const onSubmit = (data) => {
    console.log(data);
  };

  return (
    <Form noValidate onSubmit={handleSubmit(onSubmit)}>
      <Card>
        <Card.Body>
          {organisation.homes && (
            <Form.Group>
              <Form.Label>
                {t("activerecord.attributes.booking.home")}
              </Form.Label>
              <Form.Control
                ref={register("home_id")}
                as="select"
                defaultValue={booking.home_id}
              >
                {Array.from(organisation.homes).map((home) => (
                  <option key={home.id} value={home.id}>
                    {home.name}
                  </option>
                ))}
              </Form.Control>
            </Form.Group>
          )}

          <Form.Group>
            <Form.Label className="required">
              {t("activerecord.attributes.occupancy.begins_at")}
            </Form.Label>
            <Controller
              as={<CalendarControl></CalendarControl>}
              isInvalid={!!errors.begins_at}
              name="begins_at"
              defaultValue={
                booking && booking.begins_at && parseISO(booking.begins_at)
              }
              control={control}
              rules={{
                required: true,
                validate: {
                  invalidDate: (value) => isValidDate(value),
                },
              }}
            ></Controller>
            <Form.Control.Feedback type="invalid">
              {errors.begins_at && t("errors.notifications.invalid")}
            </Form.Control.Feedback>
          </Form.Group>

          <Form.Group>
            <Form.Label className="required">
              {t("activerecord.attributes.occupancy.ends_at")}
            </Form.Label>
            <Controller
              as={<CalendarControl></CalendarControl>}
              isInvalid={!!errors.ends_at}
              name="ends_at"
              control={control}
              rules={{
                required: true,
                validate: {
                  invalidDate: (value) =>
                    compareAsc(value, getValues("begins_at")) >= 0,
                },
              }}
            ></Controller>
            <Form.Control.Feedback type="invalid">
              {errors.ends_at && t("errors.notifications.invalid")}
            </Form.Control.Feedback>
          </Form.Group>

          <Form.Group>
            <Form.Label>
              {t("activerecord.attributes.booking.tenant_organisation")}
            </Form.Label>
            <Form.Control
              ref={register("tenant_organisation")}
            ></Form.Control>
          </Form.Group>

          <Form.Group>
            <Form.Label>{t("activerecord.attributes.tenant.email")}</Form.Label>
            <Form.Control
              required
              type="email"
              isInvalid={!!errors.email}
              ref={register("email", { required: true })}
            ></Form.Control>
            <Form.Control.Feedback type="invalid">
              {errors.email && t("errors.notifications.required")}
            </Form.Control.Feedback>
          </Form.Group>

          <Form.Group>
            <Form.Check type="checkbox">
              <Form.Check.Label>
                <Form.Check.Input
                  type="checkbox"
                  isInvalid={!!errors.accept_conditions}
                  ref={register("accept_conditions", { required: true })}
                ></Form.Check.Input>
                <Trans
                  i18nKey="public.bookings.new.accept_conditions_html"
                  values={{
                    privacy_statement_pdf_url:
                      organisation.links?.privacy_statement_pdf,
                    terms_pdf_url: organisation.links?.terms_pdf,
                  }}
                  components={{ a: <a /> }}
                />
              </Form.Check.Label>
              <Form.Control.Feedback type="invalid">
                {errors.accept_conditions && t("errors.notifications.accepted")}
              </Form.Control.Feedback>
            </Form.Check>
          </Form.Group>
          <Button className="mt-4" type="submit" size="lg">
            {t("public.bookings.new.submit")}
          </Button>
        </Card.Body>
      </Card>
    </Form>
  );
}
