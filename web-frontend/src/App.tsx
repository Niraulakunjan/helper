import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Home from './pages/Home.tsx';
import Login from './pages/Login.tsx';
import Register from './pages/Register.tsx';
import HelperDashboard from './pages/HelperDashboard.tsx';
import HelperSetup from './pages/HelperSetup.tsx';
import HelperDetail from './pages/HelperDetail.tsx';
import BookingForm from './pages/BookingForm.tsx';
import Chat from './pages/Chat.tsx';
import Layout from './components/Layout.tsx';
import ChatList from './pages/ChatList.tsx';


const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { user, loading } = useAuth();
  if (loading) return <div className="min-h-screen flex items-center justify-center bg-background text-primary">Loading...</div>;
  if (!user) return <Navigate to="/login" />;
  return <>{children}</>;
};

const RoleBasedRoute = () => {
  const { user } = useAuth();
  
  if (user?.role === 'helper') {
    return user.hasHelperProfile ? <HelperDashboard /> : <HelperSetup />;
  }
  
  return <Home />;
};

function AppContent() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      
      {/* Protected Layout Wrapped Routes */}
      <Route path="/" element={<ProtectedRoute><Layout><RoleBasedRoute /></Layout></ProtectedRoute>} />
      <Route path="/bookings" element={<ProtectedRoute><Layout><RoleBasedRoute /></Layout></ProtectedRoute>} />
      <Route path="/helper/:id" element={<ProtectedRoute><Layout><HelperDetail /></Layout></ProtectedRoute>} />
      <Route path="/book/:id" element={<ProtectedRoute><Layout><BookingForm /></Layout></ProtectedRoute>} />
      <Route path="/chat" element={<ProtectedRoute><Layout><ChatList /></Layout></ProtectedRoute>} />
      <Route path="/chat/:id" element={<ProtectedRoute><Layout><Chat /></Layout></ProtectedRoute>} />
      <Route path="/setup" element={<ProtectedRoute><Layout><HelperSetup /></Layout></ProtectedRoute>} />
      
      <Route path="*" element={<Navigate to="/" />} />
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="min-h-screen flex flex-col bg-background">
          <AppContent />
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
