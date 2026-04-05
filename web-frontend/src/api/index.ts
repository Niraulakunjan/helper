import axios from 'axios';

const API_BASE_URL = 'http://127.0.0.1:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add JWT token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export const authApi = {
  login: (credentials: any) => api.post('/auth/login/', credentials),
  register: (userData: any) => api.post('/auth/register/', userData),
  getProfile: () => api.get('/auth/profile/'),
};

export const serviceApi = {
  getServices: () => api.get('/services/'),
  getHelpers: () => api.get('/helpers/'),
  getHelperDetail: (id: number) => api.get(`/helpers/${id}/`),
  createHelperProfile: (profileData: any) => api.post('/helpers/register/', profileData),
};

export const bookingApi = {
  createBooking: (bookingData: any) => api.post('/bookings/', bookingData),
  getMyBookings: () => api.get('/bookings/mine/'),
  updateStatus: (id: number, status: string) => api.patch(`/bookings/${id}/status/`, { status }),
};

export const chatApi = {
  getConversations: () => api.get('/chat/conversations/'),
  getChatHistory: (otherId: number) => api.get(`/chat/${otherId}/`),
  sendMessage: (otherId: number, content: string) => api.post(`/chat/${otherId}/send/`, { content }),
};

export default api;
