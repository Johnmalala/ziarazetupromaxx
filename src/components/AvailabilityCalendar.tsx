import React from 'react';
import { DayPicker } from 'react-day-picker';
import 'react-day-picker/dist/style.css';
import { parseISO } from 'date-fns';

interface AvailabilityCalendarProps {
  availability: {
    booked_dates?: string[];
  } | null;
}

const AvailabilityCalendar: React.FC<AvailabilityCalendarProps> = ({ availability }) => {
  const bookedDates = availability?.booked_dates?.map(date => parseISO(date)) || [];

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4">
      <h3 className="text-lg font-bold mb-4 text-center">Availability</h3>
      <DayPicker
        mode="multiple"
        min={1}
        disabled={bookedDates}
        styles={{
          caption: { color: '#b91c1c' },
          head: { color: '#b91c1c' },
        }}
        modifiersClassNames={{
          disabled: 'line-through opacity-40',
        }}
      />
      <div className="mt-4 flex items-center justify-center space-x-4 text-sm">
        <div className="flex items-center space-x-2">
          <div className="w-4 h-4 bg-gray-300 rounded-sm" />
          <span>Booked</span>
        </div>
        <div className="flex items-center space-x-2">
          <div className="w-4 h-4 border border-gray-300 rounded-sm" />
          <span>Available</span>
        </div>
      </div>
    </div>
  );
};

export default AvailabilityCalendar;
