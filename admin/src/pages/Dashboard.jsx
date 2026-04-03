import { useEffect, useState } from 'react';
import { Users, Briefcase, CalendarCheck, DollarSign, Clock, CheckCircle, XCircle, TrendingUp } from 'lucide-react';
import api from '../services/api';

const StatCard = ({ icon: Icon, label, value, sub, color }) => (
  <div className="bg-[#161b22] border border-[#2d333b] rounded-lg p-5 hover:border-[#444c56] transition-colors">
    <div className="flex items-start justify-between mb-3">
      <div className={`p-2 rounded-md ${color}`}>
        <Icon size={16} className="text-[#0d1117]" />
      </div>
      <TrendingUp size={12} className="text-[#20c9c9] opacity-60" />
    </div>
    <p className="text-2xl font-bold text-[#cdd9e5]">{value}</p>
    <p className="text-xs text-[#8b949e] mt-1">{label}</p>
    {sub && <p className="text-xs text-[#20c9c9] mt-0.5">{sub}</p>}
  </div>
);

const statusColor = (s) => ({
  COMPLETED: 'text-[#20c9c9]',
  PENDING: 'text-yellow-400',
  CONFIRMED: 'text-blue-400',
  CANCELLED: 'text-red-400',
  ONGOING: 'text-purple-400',
}[s] || 'text-[#8b949e]');

export default function Dashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/admin/dashboard').then(r => { setData(r.data); setLoading(false); }).catch(() => setLoading(false));
  }, []);

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="w-5 h-5 border-2 border-[#20c9c9] border-t-transparent rounded-full animate-spin"/>
    </div>
  );

  const { stats, recentBookings, recentUsers } = data;

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-[#cdd9e5]">Dashboard</h1>
          <p className="text-sm text-[#8b949e]">Platform overview</p>
        </div>
        <div className="px-3 py-1.5 bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-20 rounded-md">
          <span className="text-[#20c9c9] text-xs font-medium">Live data</span>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon={Users} label="Total Users" value={stats.totalUsers} color="bg-[#20c9c9]" />
        <StatCard icon={Briefcase} label="Providers" value={stats.totalProviders} color="bg-purple-400" />
        <StatCard icon={CalendarCheck} label="Bookings" value={stats.totalBookings} color="bg-blue-400" />
        <StatCard icon={DollarSign} label="Revenue" value={`$${stats.totalRevenue}`} color="bg-[#20c9c9]" />
      </div>

      <div className="grid grid-cols-3 gap-4">
        <StatCard icon={Clock} label="Pending" value={stats.pendingBookings} color="bg-yellow-400" />
        <StatCard icon={CheckCircle} label="Completed" value={stats.completedBookings} color="bg-[#20c9c9]" />
        <StatCard icon={XCircle} label="Cancelled" value={stats.cancelledBookings} color="bg-red-400" />
      </div>

      {/* Tables */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Recent Bookings */}
        <div className="bg-[#161b22] border border-[#2d333b] rounded-lg overflow-hidden">
          <div className="px-5 py-3 border-b border-[#2d333b] flex items-center justify-between">
            <h2 className="text-sm font-medium text-[#cdd9e5]">Recent Bookings</h2>
            <span className="text-xs text-[#8b949e]">{recentBookings.length} entries</span>
          </div>
          <div className="divide-y divide-[#21262d]">
            {recentBookings.map((b) => (
              <div key={b.id} className="px-5 py-3 flex items-center justify-between hover:bg-[#1c2128] transition-colors">
                <div>
                  <p className="text-sm text-[#cdd9e5] font-medium">{b.user.fullName}</p>
                  <p className="text-xs text-[#8b949e]">{b.service.name}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-semibold text-[#20c9c9]">${b.totalPrice}</p>
                  <p className={`text-xs font-medium ${statusColor(b.status)}`}>{b.status}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Users */}
        <div className="bg-[#161b22] border border-[#2d333b] rounded-lg overflow-hidden">
          <div className="px-5 py-3 border-b border-[#2d333b] flex items-center justify-between">
            <h2 className="text-sm font-medium text-[#cdd9e5]">Recent Users</h2>
            <span className="text-xs text-[#8b949e]">{recentUsers.length} entries</span>
          </div>
          <div className="divide-y divide-[#21262d]">
            {recentUsers.map((u) => (
              <div key={u.id} className="px-5 py-3 flex items-center gap-3 hover:bg-[#1c2128] transition-colors">
                <div className="w-7 h-7 rounded-full bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-20 flex items-center justify-center text-xs font-bold text-[#20c9c9]">
                  {u.fullName.charAt(0)}
                </div>
                <div>
                  <p className="text-sm text-[#cdd9e5] font-medium">{u.fullName}</p>
                  <p className="text-xs text-[#8b949e]">{u.email}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}