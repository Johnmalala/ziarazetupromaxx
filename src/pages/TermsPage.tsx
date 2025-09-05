import React from 'react';

const TermsPage: React.FC = () => {
  return (
    <div className="min-h-screen pt-16">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h1 className="text-3xl font-bold mb-6">Terms of Service</h1>
        <div className="prose lg:prose-xl">
          <p>Last updated: July 2025</p>
          
          <h2>1. Agreement to Terms</h2>
          <p>
            By using our services, you agree to be bound by these Terms of Service.
          </p>

          <h2>2. Bookings and Payments</h2>
          <p>
            All bookings are subject to availability. We require payment at the time of booking, which can be a full payment, a deposit, or an installment plan as specified.
          </p>
          
          <h2>3. Cancellations and Refunds</h2>
          <p>
            Our cancellation policy varies depending on the tour or service booked. Please refer to the specific cancellation details provided at the time of booking.
          </p>

          <h2>4. Limitation of Liability</h2>
          <p>
            Ziarazetu is not liable for any personal injury, property damage, or other loss that may occur during your trip.
          </p>

          <p>
            [This is a placeholder terms of service. Please replace with your own.]
          </p>
        </div>
      </div>
    </div>
  );
};

export default TermsPage;
