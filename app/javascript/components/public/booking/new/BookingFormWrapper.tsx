import * as React from "react";
import { Card, Alert } from "react-bootstrap";
import { useTranslation, Trans } from "react-i18next";
import { BookingJsonData, Booking, fromJson as bookingFromJson } from "../../../../models/Booking";
import { Organisation } from "../../../../models/Organisation";
import axios, { AxiosError } from "axios";
import { getCsrfToken } from "../../../../services/csrf";
import { BookingForm, ErrorMessages } from "./BookingForm";

function preparePostData(booking: Booking) {
  return {
    home_id: booking.home_id,
    email: booking.email,
    accept_conditions: booking.accept_conditions,
    occupancy_attributes: {
      begins_at: booking.begins_at,
      ends_at: booking.ends_at,
    },
    tenant_organisation: booking.tenant_organisation,
  };
}

interface BookingFormWrapperProps {
  booking: BookingJsonData;
  organisation: Organisation;
}

type SubmitState = {
  errors?: ErrorMessages;
  ok?: boolean;
  isSubmitting?: boolean;
  submittedTo?: string;
};

export default function BookingFormWrapper({ booking, organisation }: BookingFormWrapperProps) {
  const { t } = useTranslation();
  const [submitState, setSubmitState] = React.useState<SubmitState>({
    isSubmitting: undefined,
    ok: undefined,
    errors: undefined,
  });
  const handleSubmit = async (data: Booking) => {
    try {
      setSubmitState({
        isSubmitting: true,
        ok: undefined,
        errors: undefined,
      });
      const response = await axios.post(organisation.links.post_bookings, {
        booking: preparePostData(data),
        authenticity_token: getCsrfToken(),
      });
      setSubmitState({
        isSubmitting: false,
        ok: response.status == 201,
        errors: undefined,
        submittedTo: data.email,
      });
    } catch (axiosError) {
      const error = axiosError as AxiosError;
      setSubmitState({
        isSubmitting: false,
        ok: false,
        errors: error.response?.data?.errors as ErrorMessages,
      });
    }
  };
  if (submitState.ok === true) {
    return (
      <Card border="success">
        <Card.Body className="text-center">
          <i style={{ fontSize: "10em" }} className="fa fa-calendar-check-o mb-3 text-success" />
          <p>
            <Trans
              i18nKey="flash.public.bookings.create.notice"
              t={t}
              values={{ email: submitState.submittedTo }}
              components={{ strong: <strong /> }}
            />
          </p>
        </Card.Body>
      </Card>
    );
  }

  return (
    <Card border={(submitState.ok === false && "danger") || ""}>
      <Card.Body>
        {submitState.ok === false && (
          <Alert variant="danger">
            <>
              <i className="fa fa-exclamation-circle me-3" />
              {submitState.errors?.base?.join(", ") ||
                t("flash.actions.create.alert", {
                  resource_name: t("activerecord.models.booking.one"),
                })}
            </>
          </Alert>
        )}

        {organisation.links.logo && (
          <img
            src={organisation.links.logo}
            className="mx-auto d-block m-4"
            style={{ maxWidth: "180px", maxHeight: "180px" }}
          />
        )}
        <BookingForm
          booking={bookingFromJson(booking)}
          onSubmit={handleSubmit}
          organisation={organisation}
          errors={submitState.errors}
        ></BookingForm>
      </Card.Body>
    </Card>
  );
}
