import { create } from 'zustand';

const useAuthStore = create((set) => ({
  admin: JSON.parse(localStorage.getItem('adminData')) || null,
  token: localStorage.getItem('adminToken') || null,

  setAuth: (admin, token) => {
    localStorage.setItem('adminToken', token);
    localStorage.setItem('adminData', JSON.stringify(admin));
    set({ admin, token });
  },

  logout: () => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminData');
    set({ admin: null, token: null });
  },
}));

export default useAuthStore;