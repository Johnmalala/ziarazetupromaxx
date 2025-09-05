import React from 'react';
import { Toaster } from 'react-hot-toast';

const ToasterProvider: React.FC = () => {
  return (
    <Toaster
      position="top-center"
      reverseOrder={false}
      toastOptions={{
        style: {
          background: '#333',
          color: '#fff',
        },
      }}
    />
  );
};

export default ToasterProvider;
