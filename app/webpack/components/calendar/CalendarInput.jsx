import React, { useState } from 'react'
import CalendarControl from './CalendarControl'
import { Form } from 'react-bootstrap'

const CalendarInput = ({ value, name, label, required = false, disabled = false }) => {
  return (
    <Form.Group disabled={disabled}>
      {label && <Form.Label className={required && "required"}>{label}</Form.Label>}
      <CalendarControl value={value} name={name} required={required}></CalendarControl>
    </Form.Group>
  )
}

export default CalendarInput