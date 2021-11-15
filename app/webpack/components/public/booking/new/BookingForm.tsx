import * as React from "react";
import { useForm, Controller } from "react-hook-form";
import { Form, Button } from "react-bootstrap";
import CalendarControl from "../../../calendar/CalendarControl";
import { Trans, useTranslation } from "react-i18next";
import { isValid as isValidDate, compareAsc } from "date-fns/esm";
import { Booking } from "../../../../models/Booking";
import { Organisation } from "../../../../models/Organisation";

export type ErrorMessages = {
  [index: string]: string[];
};

type FormKey =
  | "email"
  | "occupancy.begins_at"
  | "occupancy.ends_at"
  | "accept_conditions"
  | "tenant_organisation";

interface BookingFormProps {
  booking: Booking;
  organisation: Organisation;
  onSubmit: (data: Booking) => void;
  errors?: ErrorMessages;
}

export function BookingForm({
  booking,
  organisation,
  onSubmit,
  errors: submitErrors,
}: BookingFormProps) {
  const { t } = useTranslation();
  const {
    register,
    handleSubmit,
    clearErrors,
    getValues,
    setError,
    setValue,
    control,
    formState: { errors },
  } = useForm<Booking>({
    mode: "onChange",
    defaultValues: booking,
  });

  React.useEffect(() => {
    if (!submitErrors) return;
    const keys: FormKey[] = [
      "email",
      "occupancy.begins_at",
      "occupancy.ends_at",
      "accept_conditions",
      "tenant_organisation",
    ];
    for (const errorKey of keys) {
      const errorMessages = submitErrors[errorKey];
      errorMessages
        ? setError(errorKey, {
          type: "submit",
          message: errorMessages?.join(", "),
        })
        : clearErrors(errorKey);
    }
  }, [submitErrors]);

  return (
    <Form noValidate onSubmit={handleSubmit(onSubmit)}>
      {organisation.homes && (
        <Form.Group className="mb-3">
          <Form.Label>{t("activerecord.attributes.booking.home")}</Form.Label>
          <Form.Control
            {...register("home_id")}
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

      <Form.Group className="mb-3">
        <Form.Label className="required">
          {t("activerecord.attributes.occupancy.begins_at")}
        </Form.Label>
        <Controller
          render={({
            field: { onChange, onBlur, value, name },
            fieldState: { error },
          }) => (
            <CalendarControl
              isInvalid={!!error}
              onBlur={onBlur}
              onChange={(value) => {
                compareAsc(value, getValues("occupancy.ends_at")) > 0 &&
                  setValue("occupancy.ends_at", value);
                onChange(value);
              }}
              value={value}
              name={name}
              invalidFeedback={errors.occupancy?.begins_at?.message}
            />
          )}
          name="occupancy.begins_at"
          control={control}
          rules={{
            required: t("errors.notifications.required").toString(),
            validate: {
              invalidDate: (value) =>
                isValidDate(value) ||
                t("errors.notifications.invalid").toString(),
              future: (value) =>
                compareAsc(value, new Date()) >= 0 ||
                t("errors.notifications.future").toString(),
            },
          }}
        ></Controller>
      </Form.Group>

      <Form.Group className="mb-3">
        <Form.Label className="required">
          {t("activerecord.attributes.occupancy.ends_at")}
        </Form.Label>
        <Controller
          render={({
            field: { onChange, onBlur, value, name },
            fieldState: { error },
          }) => (
            <CalendarControl
              isInvalid={!!error}
              invalidFeedback={errors.occupancy?.ends_at?.message}
              onBlur={onBlur}
              onChange={onChange}
              value={value}
              name={name}
            />
          )}
          name="occupancy.ends_at"
          control={control}
          rules={{
            required: t("errors.notifications.required").toString(),
            validate: {
              invalidDate: (value) =>
                isValidDate(value) ||
                t("errors.notifications.invalid").toString(),
              laterThanStart: (value) =>
                compareAsc(value, getValues("occupancy.begins_at")) >= 0 ||
                t("errors.notifications.later_than", {
                  other: t(
                    "activerecord.attributes.occupancy.begins_at"
                  ).toString(),
                }).toString(),
            },
          }}
        ></Controller>
      </Form.Group>

      <Form.Group className="mb-3">
        <Form.Label className="required">
          {t("activerecord.attributes.tenant.email")}
        </Form.Label>
        <Form.Control
          required
          type="email"
          isInvalid={!!errors.email}
          {...register("email", {
            validate: {
              email: (value) =>
                /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) ||
                t("errors.notifications.invalid").toString(),
            },
          })}
        ></Form.Control>
        <Form.Control.Feedback type="invalid">
          {errors.email?.message}
        </Form.Control.Feedback>
      </Form.Group>

      <Form.Group className="mb-3">
        <Form.Label>
          {t("activerecord.attributes.booking.tenant_organisation")}
        </Form.Label>
        <Form.Control {...register("tenant_organisation")}></Form.Control>
      </Form.Group>

      <a href="../agent_bookings/new">{t("activerecord.models.booking_agent.other")}</a>

      <Form.Group className="mb-3 mt-5">
        <Form.Check
          type="checkbox"
          feedbackType="invalid"
          feedback={errors.accept_conditions?.message}
          isInvalid={!!errors.accept_conditions}
          id="accept_conditions"
          label={
            <Trans
              i18nKey="public.bookings.new.accept_conditions_html"
              values={{
                privacy_statement_pdf_url:
                  organisation.links?.privacy_statement_pdf,
                terms_pdf_url: organisation.links?.terms_pdf,
              }}
              components={{ a: <a /> }}
            />
          }
          {...register("accept_conditions", {
            required: t("errors.notifications.accepted").toString(),
          })}
        ></Form.Check>
      </Form.Group>
      <Button className="mt-4" type="submit" size="lg">
        {t("public.bookings.new.submit")}
      </Button>
    </Form>
  );
}
