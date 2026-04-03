import { useState } from 'react';
import toast from 'react-hot-toast';
import api from '../services/api';
import useAuthStore from '../store/authStore';

export default function Settings() {
  const admin = useAuthStore((state) => state.admin);
  const [form, setForm] = useState({ currentPassword: '', newPassword: '', confirmPassword: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (form.newPassword !== form.confirmPassword) { toast.error('Passwords do not match'); return; }
    setLoading(true);
    try {
      await api.put('/admin/change-password', { currentPassword: form.currentPassword, newPassword: form.newPassword });
      toast.success('Password changed!');
      setForm({ currentPassword: '', newPassword: '', confirmPassword: '' });
    } catch (err) { toast.error(err.response?.data?.message || 'Failed'); }
    finally { setLoading(false); }
  };

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-lg font-semibold text-[#cdd9e5]">Settings</h1>
        <p className="text-sm text-[#8b949e]">Manage your account</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Profile */}
        <div className="bg-[#161b22] border border-[#2d333b] rounded-lg p-6">
          <h2 className="text-sm font-medium text-[#cdd9e5] mb-4 pb-3 border-b border-[#2d333b]">Account Info</h2>
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-full bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-20 flex items-center justify-center text-2xl font-bold text-[#20c9c9]">
              {admin?.fullName?.charAt(0)}
            </div>
            <div>
              <p className="font-semibold text-[#cdd9e5]">{admin?.fullName}</p>
              <p className="text-sm text-[#8b949e]">{admin?.email}</p>
              <span className="text-xs px-2 py-0.5 rounded-full bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border border-[#20c9c9] border-opacity-20 mt-1 inline-block">{admin?.role}</span>
            </div>
          </div>
        </div>

        {/* Change Password */}
        <div className="bg-[#161b22] border border-[#2d333b] rounded-lg p-6">
          <h2 className="text-sm font-medium text-[#cdd9e5] mb-4 pb-3 border-b border-[#2d333b]">Change Password</h2>
          <form onSubmit={handleSubmit} className="space-y-3">
            {[['currentPassword','Current Password'],['newPassword','New Password'],['confirmPassword','Confirm Password']].map(([key,label]) => (
              <div key={key}>
                <label className="block text-xs text-[#8b949e] mb-1">{label}</label>
                <input type="password" value={form[key]} onChange={e => setForm({...form,[key]:e.target.value})}
                  className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]" required/>
              </div>
            ))}
            <button type="submit" disabled={loading}
              className="w-full py-2 text-sm bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] rounded-md hover:bg-opacity-20 transition-colors disabled:opacity-50 mt-2">
              {loading ? 'Updating...' : 'Update Password'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
