import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import HomePage from './pages/HomePage';
import ToursPage from './pages/ToursPage';
import TourDetailsPage from './pages/TourDetailsPage';
import StaysPage from './pages/StaysPage';
import StayDetailsPage from './pages/StayDetailsPage';
import VolunteerPage from './pages/VolunteerPage';
import VolunteerDetailsPage from './pages/VolunteerDetailsPage';
import CustomPackagesPage from './pages/CustomPackagesPage';
import SignInPage from './pages/SignInPage';
import SignUpPage from './pages/SignUpPage';
import ProfilePage from './pages/ProfilePage';
import BookingsPage from './pages/BookingsPage';
import BookingPage from './pages/BookingPage';
import PrivacyPage from './pages/PrivacyPage';
import TermsPage from './pages/TermsPage';
import ToasterProvider from './components/ToasterProvider';

function App() {
  return (
    <Router>
      <ToasterProvider />
      <div className="min-h-screen flex flex-col pt-16">
        <Navbar />
        <main className="flex-grow">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/tours" element={<ToursPage />} />
            <Route path="/tours/:id" element={<TourDetailsPage />} />
            <Route path="/stays" element={<StaysPage />} />
            <Route path="/stays/:id" element={<StayDetailsPage />} />
            <Route path="/volunteer" element={<VolunteerPage />} />
            <Route path="/volunteer/:id" element={<VolunteerDetailsPage />} />
            <Route path="/custom-packages" element={<CustomPackagesPage />} />
            <Route path="/signin" element={<SignInPage />} />
            <Route path="/signup" element={<SignUpPage />} />
            <Route path="/profile" element={<ProfilePage />} />
            <Route path="/bookings" element={<BookingsPage />} />
            <Route path="/book/:type/:id" element={<BookingPage />} />
            <Route path="/privacy" element={<PrivacyPage />} />
            <Route path="/terms" element={<TermsPage />} />
          </Routes>
        </main>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
