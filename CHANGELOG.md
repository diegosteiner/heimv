# Changelog

## Unreleased

## Version 23.11.1

- Bugfixes

## Version 23.10.2

- Improvement: Recognize payment duplicates more accurately
- Feature: Edit contract and invoice emails before send
- Updates

## Version 23.10.1

- Improvement: Limit year calender scroll to 1 month
- Bugfixes

## Version 23.9.3

- Feature: Allow deadlines to be 0 in settings to skip
- Bugfixes

## Version 23.9.2

- Feature: Notify operators for upcoming bookings
- Feature: Embed tenant information in private ical
- Feature: Add more fields for booking agents

## Version 23.9.1

- Bugfixes
- Feature: Show current date in calendar
- Feature: Translate occupiable names and descriptions

## Version 23.8.3

Released on 24.08.2023

- Feature: Add more control over booking_questions
- Feature: Add organisation changer in footer

## Version 23.8.2

Released on 22.08.2023

- Bugfixes
- Updates

## Version 23.8.1

Released on 15.08.2023

- Feature: Add VAT to invoice parts

## Version 23.7.3

Released on 25.07.2023

- Bugfixes

## Version 23.7.2

Released on 13.07.2023

- Feature: Rework BookingConditions and add new ones

## Version 23.7.1

Released on 11.07.2023

- Feature: Add soft delete for booking categories
- Feature: Add custom booking questions
- Fix: Implement QR bill standards more closely
- Feature: Add definitive state options for organisation

## Version 23.6.2

Released on 27.06.2023

- Feature: Add plan_b backups
- Feature: Add InvoicePart data digests

## Version 23.6.1

Released on 01.06.2023

- Fix: Allow managers to add occupancies
- Fix: Add locale to invoices and contracts
- Feature: Add tenant data digest
- Feature: Add ignore_conflicts to bookings and occupancies
- Feature: Hide categories when theres only one
- Feature: Improve navigation for managers

## Version 23.5.2

Released on 21.05.2023

- Fix: Percentage invoice parts
- Fix: Calendar popovers and responsiveness
- Fix: Locale for pdfs

## Version 23.5.1

Released on 12.05.2023

- Feature: Group invoice parts
- Fix: ICAL Links

## Version 23.4.2

Released on 24.04.2023

- Fix: SVG calendar icons
- Fix: Show definitive_requests as occupied in calendar
- Improvement: Selection of occupiables
- Improvement: Add more french translations (Thanks Yannick Wehrli)

## Version 23.4.1

Released on 15.04.2023

- Feature: Calendar view is switchable
- Feature: Extras in Templates
- Fix: Import of bookings
- Fix: Calendar perfomance

## Version 23.3.1

Released on 13.03.2023

- Feature: Bookings can now have multiple occupancies
- Feature: Add new role "administrator" with full rights on organisation
- Feature: Add new notification for completed bookings
- Improvement: Add french and italian translations (Thanks Yannick Wehrli and Rolf Steiner)
- Improvement: Add better errors for import of occupancies

## Version 23.2.2

Released on 13.02.2023

- Fix min occupation tarif
- Update ruby version to 3.2
- Add deadline for awaiting tenant and payment overdue

## Version 23.1.2

Released on 31.01.2023

- Improve form for booking agents
- Add config for default times

## Version 23.1.1

Released on 13.01.2023

- Add filter for invoices
- Add data_digest for invoices
- Normalize typography

## Version 22.12.2

Released on 23.12.2022

- Allow bookings to occupy multiple homes
- Add conditions to designated documents and responsibilities

## Version 22.12.1

Released on 02.12.2022

- Improve Booking Conditions
- Tweak UI

## Version 22.11.1

Released on 30.11.2022

- Refactor data_digests
- Add worker queue for background jobs
- Simplify process to create late notices from invoices

## Version 22.10.3

Released on 12.10.2022

- Improvement: Add better help for variables for rich text templates
- Fix: Allow change of locale

## Version 22.10.2

Released on 09.10.2022

- Feature: Add organisation-wide tarifs and bookable extras

## Version 22.10.1

Released on 01.10.2022

- Feature: Create offers through invoices
- Fix: Remove orange payment slip
- Fix: Show all homes on dashboard

## Version 22.9.3

Released on 16.09.2022

- Fix: MinOccupation tarif calculations

## Version 22.9.2

Released on 07.09.2022

- Feature: Set a minimum price per tarif
- Fix: Checkmarks for entering usages
- Feature: Jump directly to new invoice after entering usages

## Version 22.9.1

Released on 07.09.2022

- Feature: Unify tarifs and usages in a single tab
- Feature: Set indiviual colors for occupancies through booking
- Feature: Define multiple associated_types per tarif
- Fix: Show invoice_parts for missing usages

## Version 22.8.2

Released on 24.08.2022

- Feature: Log activities on bookings
- Feature: Add warnings when booking is not yet committed

## Version 22.8.1

Released on 19.08.2022

- Feature: Add logs for booking updates and actions
- Feature: Make data digests columns configurable (admin only)
- Fix: Calculation for MeterReadingPeriod usages

## Version 22.7.1

Released on 17.07.2022

- Fix small bugs and update dependencies

## Version 22.6.2

Released on 26.06.2022

- Add checklist item for payment_due
- Fix purpose_description field in booking form
- Fix DE typos
- Add booked_extras to serializer so it can be used in contract

## Version 22.6.1

Released on 09.06.2022

- Rename booking_purposes to booking_categories and add description
- Fix for overpaid invoices
- Assign responsibilities earlier

## Version 22.5.2

Released on 30.05.2022

- Add new validations for bookings
- Fix problems with locales other than DE
- Hide send contract button when booking is not definintive
- Set automatic operator-responsibilities earlier in the process

## Version 22.5.1

Released on 17.05.2022

- Fix agent bookings where no email was sent out
- Fix missing attachments on notifications
- Move Rich Text Template help to form
- Fix operator emails that are not sent out
- Add creditor adress to organisation
- Fix redirection issue after login

## Version 22.4.2

Released on 21.04.2022

- Improve performance of datetime control
- Add configurable color to occupancies
- Allow birthdates to be optional
- Add configurable durations per home

## Version 22.4.1

Released on 04.04.2022

- Fix bug that reassigns operators
- Add new tarif selector OccupancyDuration
- Add new Tarif Price
- Add more fields to tenant serializer

## Version 22.3.2

Released on 23.03.2022

- Allow disabling of rich_text templates
- Show all designated documents in overview

## Version 22.3.1

Released on 11.03.2022

- Add bookable extras
- Fix missing translations for contracts and invoices

## Version 22.2.3

Released on 22.02.2022

- Replace sentry with email based error_notifications
- Remove old framework defaults

## Version 22.2.2

Released on 07.02.2022

- Improve handling of designated documents
- Add more time options for data digests

## Version 22.2.1

Released on 02.02.2022

- Add usage support for import

## Version 22.1.1

Released on 23.01.2022

- Extract documents into new model
- Improve import for bookings
- Fix some default rich text templates
- Allow cancellation from more states

## Version 21.11.2

Released on 17.11.2021

- Improve operators and responsibilities
- Fix layout issues
- Fix tarif importer
- Add new invoice position for discounts

## Version 21.11.1

Released on 05.11.2021

- Add operators with responsibilities
- Improve notifications
- Improve calendar performance

## Version 21.10.1

Released on 22.10.2021

- Add liquid validations for richtext templates
- Add UI for booking import
- Update JS Dependencies

## Version 21.9.2

Released on 15.09.2021

- Overhaul privacy statement

## Version 21.9.1

Released on 11.09.2021

- Richtext Templates are now editabe with editor
- Fix invitations von user
- Upgrade to ruby 3.0

## Version 21.8.1

Released on 31.08.2021

- Small improvements on notifications
- Show tenants now includes bookings

## Version 21.7.1

Released on 20.07.2021

- Allow tenants to make bookings without contracts (fast lane)
- Improve navigation on mobile
- Small bugfixes and updates

## Version 21.6.2

Released on 27.06.2021

- Bugfixes
- Send notification when booking becomes definitive
- Add IBAN to payment_infos

## Version 21.6.1

Released on 08.06.2021

- Add page header to all pdfs
- Add link to guide

## Version 21.5.3

Released on 2021-05-24

- Improve navigation on bookings
- Fix payment import on iPads
- Add restricted access for read-only users

## Version 21.5.2

Released on 2021-05-09

- Fixes for state_transition
- Fixes for payment notification
- Improve csv import

## Version 21.5.1

Released on 2021-05-04

- Show internal remarks in bookings overview
- Add possibility to translate tarifs
- Allow ordering of booking purposes

## Version 21.4.2

Released on 2021-04-22

- Add nickname to tenants
- Add tenant and tarif importer
- Bugfixes

## Version 21.4.1

Released on 2021-04-19

- Use correct address when creating contracts
- Change internal rich text handling
- Refactor booking flow and add documentation
- Add more caching for better performance
- Add canned filters

## Version 21.3.1

Released on 2021-03-13

- Bugfixes and updates

## Version 21.2.3

Released on 2021-02-27

- Introduce QR Bill
- Add import from csv for bookings

## Version 21.2.2

Released on 2021-02-14

- Add prefix for ESR reference numbers
- Rename ESR beneficiary account
- Move ref_template to organisation
- Fixed some translations

## Version 21.2.1

Released on 2021-02-07

- Improve checkbox actions to be more direct
- Small bugfixes

## Version 21.1.3

Released on 2021-01-30

- Add more flexible system for booking references
- Improve organisation setup service

## Version 21.1.2

Released on 2021-01-10

- Fix bugs in smtp_config

## Version 21.1.1

## Version 20.12.2

Released on 2020-12-26

- Improve deadline edit
- Improve booking form for manager
- Improve invoices overview

## Version 20.12.1

Released on 2020-12-07

- Improve late notices
- Restructure organisation settings
- Allow customization of booking purposes

## Version 20.11.4

Released on 2020-11-29

- Simplify templates
- Improve localization support

## Version 20.10.2

Released on 2020-10-11

- Improve RichTextTemplate overview
- Allow managers to change tenant on booking
- Remove automatic decline when awaiting_tenant

## Version 20.10.1

Released on 2020-10-01

- Improve user management
- Improve development setup

## Version 20.9.2

Released on 2020-09-24

- Update dependencies
- Improve multi organisation support
- Add namespace support for templates
- Release code as open-source

## Version 20.9.1

Released on 2020-09-04

- Improve multi organisation support
- Improve locale support

## Version 20.8.5

Released on 2020-08-30

- Improved error pages
- Changed behaviour after login
- Bugfixes

## Version 20.8.4

Released on 2020-08-25

- Bugfixes
