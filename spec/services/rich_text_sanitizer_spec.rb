# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RichTextSanitizer, type: :service do
  subject(:service) { described_class }

  describe '::sanitize' do
    subject(:sanitize) { described_class.sanitize(html) }

    context 'with allowed html' do
      let(:html) do
        <<~HTML
          <h1>Rental Contract Overview</h1>
             <p>This document outlines the key elements of the rental contract between the landlord and tenant.</p>

             <h2>Table of Contents</h2>
             <ol>
                 <li><a href="#parties">Parties Involved</a></li>
                 <li><a href="#property">Property Details</a></li>
                 <li><a href="#terms">Terms of Lease</a></li>
                 <li><a href="#payments">Payment Details</a></li>
                 <li><a href="#signatures">Signatures</a></li>
             </ol>

             <h3>Parties Involved</h3>
             <p><strong>Landlord:</strong> John Doe</p>
             <p><em>Tenant:</em> Jane Smith</p>

             <h3>Property Details</h3>
             <p>Located at <strong>123 Main Street, Anytown, Anystate</strong>, this property is a two-bedroom apartment on the second floor with a balcony.</p>
             <img src="property.jpg" alt="Image of the property" width="500" height="300">

             <h3>Terms of Lease</h3>
             <ul>
                 <li>Lease Start Date: January 1, 2023</li>
                 <li>Lease End Date: December 31, 2023</li>
                 <li>No pets allowed</li>
                 <li>No smoking inside the property</li>
             </ul>

             <h3>Payment Details</h3>
             <table>
                 <tr>
                     <th>Payment Type</th>
                     <th>Amount</th>
                     <th>Due Date</th>
                 </tr>
                 <tr>
                     <td>Monthly Rent</td>
                     <td>$1,200</td>
                     <td>First of the month</td>
                 </tr>
                 <tr>
                     <td>Security Deposit</td>
                     <td>$2,400</td>
                     <td>Upon signing</td>
                 </tr>
             </table>

             <h3>Signatures</h3>
             <p>This section would typically contain spaces for both the landlord and tenant to sign, indicating their agreement to the terms outlined in the contract.</p>

        HTML
      end

      it { is_expected.to eq(html) }
    end
  end
end
