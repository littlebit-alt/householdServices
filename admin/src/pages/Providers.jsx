import { useEffect, useState } from 'react';
import { Search, ToggleLeft, ToggleRight, Trash2, Plus, Star, Wrench, X } from 'lucide-react';
import api from '../services/api';
import toast from 'react-hot-toast';

export default function Providers() {
  const [providers, setProviders] = useState([]);
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [showServiceModal, setShowServiceModal] = useState(false);
  const [selectedProvider, setSelectedProvider] = useState(null);
  const [serviceForm, setServiceForm] = useState({ serviceId: '', price: '' });
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', password: '', bio: '' });

  const fetchProviders = async () => {
    try {
      const r = await api.get('/providers');
      setProviders(r.data.providers);
    } catch { toast.error('Failed to fetch providers'); }
    finally { setLoading(false); }
  };

  const fetchServices = async () => {
    try {
      const r = await api.get('/services');
      setServices(r.data.services);
    } catch { console.error('Failed to fetch services'); }
  };

  useEffect(() => { fetchProviders(); fetchServices(); }, []);

  const handleVerify = async (id) => {
    try { await api.put(`/providers/${id}/verify`); toast.success('Provider verified!'); fetchProviders(); }
    catch { toast.error('Failed to verify'); }
  };

  const handleToggle = async (id) => {
    try { const r = await api.put(`/providers/${id}/toggle-status`); toast.success(r.data.message); fetchProviders(); }
    catch { toast.error('Failed to update'); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete this provider?')) return;
    try { await api.delete(`/providers/${id}`); toast.success('Deleted'); fetchProviders(); }
    catch { toast.error('Failed to delete'); }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await api.post('/providers/register', form);
      toast.success('Provider created!');
      setShowModal(false);
      setForm({ fullName: '', email: '', phone: '', password: '', bio: '' });
      fetchProviders();
    } catch (err) { toast.error(err.response?.data?.message || 'Failed'); }
  };

  const openServiceModal = (provider) => {
    setSelectedProvider(provider);
    setServiceForm({ serviceId: '', price: '' });
    setShowServiceModal(true);
  };

  const handleAddService = async (e) => {
    e.preventDefault();
    try {
      await api.post(`/providers/${selectedProvider.id}/services`, {
        serviceId: parseInt(serviceForm.serviceId),
        price: parseFloat(serviceForm.price),
      });
      toast.success(`Service added to ${selectedProvider.fullName}!`);
      setShowServiceModal(false);
      fetchProviders();
    } catch (err) { toast.error(err.response?.data?.message || 'Failed to add service'); }
  };

  const filtered = providers.filter(p =>
    p.fullName.toLowerCase().includes(search.toLowerCase()) ||
    p.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-6 space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-[#cdd9e5]">Providers</h1>
          <p className="text-sm text-[#8b949e]">{providers.length} service providers</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8b949e]" />
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search..."
              className="pl-9 pr-4 py-2 text-sm bg-[#161b22] border border-[#2d333b] rounded-md text-[#cdd9e5] placeholder-[#8b949e] focus:outline-none focus:border-[#20c9c9] w-48"/>
          </div>
          <button onClick={() => setShowModal(true)}
            className="flex items-center gap-2 px-3 py-2 bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] text-sm rounded-md hover:bg-opacity-20 transition-colors">
            <Plus size={14}/> Add Provider
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="bg-[#161b22] border border-[#2d333b] rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#2d333b]">
              {['Provider', 'Phone', 'Rating', 'Verified', 'Status', 'Actions'].map(h => (
                <th key={h} className="px-5 py-3 text-left text-xs font-medium text-[#8b949e] uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-[#21262d]">
            {loading && <tr><td colSpan={6} className="px-5 py-8 text-center"><div className="w-5 h-5 border-2 border-[#20c9c9] border-t-transparent rounded-full animate-spin mx-auto"/></td></tr>}
            {!loading && filtered.length === 0 && <tr><td colSpan={6} className="px-5 py-8 text-center text-[#8b949e]">No providers found</td></tr>}
            {filtered.map(p => (
              <tr key={p.id} className="hover:bg-[#1c2128] transition-colors">
                <td className="px-5 py-3">
                  <div className="flex items-center gap-3">
                    <div className="w-7 h-7 rounded-full bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-20 flex items-center justify-center text-xs font-bold text-[#20c9c9]">
                      {p.fullName.charAt(0)}
                    </div>
                    <div>
                      <p className="font-medium text-[#cdd9e5]">{p.fullName}</p>
                      <p className="text-xs text-[#8b949e]">{p.email}</p>
                    </div>
                  </div>
                </td>
                <td className="px-5 py-3 text-[#8b949e]">{p.phone}</td>
                <td className="px-5 py-3">
                  <div className="flex items-center gap-1">
                    <Star size={12} className="text-yellow-400 fill-yellow-400"/>
                    <span className="text-[#cdd9e5] text-xs">{p.rating} ({p.totalReviews})</span>
                  </div>
                </td>
                <td className="px-5 py-3">
                  {p.isVerified
                    ? <span className="text-xs px-2 py-1 rounded-full bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border border-[#20c9c9] border-opacity-20">Verified</span>
                    : <button onClick={() => handleVerify(p.id)} className="text-xs px-2 py-1 rounded-full bg-[#2d333b] text-[#8b949e] hover:text-[#20c9c9] border border-[#2d333b] transition-colors">Verify</button>
                  }
                </td>
                <td className="px-5 py-3">
                  <span className={`text-xs px-2 py-1 rounded-full border ${p.isActive ? 'bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border-[#20c9c9] border-opacity-20' : 'bg-red-400 bg-opacity-10 text-red-400 border-red-400 border-opacity-20'}`}>
                    {p.isActive ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-5 py-3">
                  <div className="flex items-center gap-2">
                    <button onClick={() => openServiceModal(p)} className="text-[#8b949e] hover:text-[#20c9c9] transition-colors" title="Add Service">
                      <Wrench size={15}/>
                    </button>
                    <button onClick={() => handleToggle(p.id)} className="text-[#8b949e] hover:text-[#20c9c9] transition-colors">
                      {p.isActive ? <ToggleRight size={18}/> : <ToggleLeft size={18}/>}
                    </button>
                    <button onClick={() => handleDelete(p.id)} className="text-[#8b949e] hover:text-red-400 transition-colors">
                      <Trash2 size={15}/>
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Create Provider Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50">
          <div className="bg-[#161b22] border border-[#2d333b] rounded-lg p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-base font-semibold text-[#cdd9e5]">Add Provider</h2>
              <button onClick={() => setShowModal(false)} className="text-[#8b949e] hover:text-[#cdd9e5]"><X size={16}/></button>
            </div>
            <form onSubmit={handleCreate} className="space-y-3">
              {[['fullName','Full Name','text'],['email','Email','email'],['phone','Phone','text'],['password','Password','password'],['bio','Bio (optional)','text']].map(([key,label,type]) => (
                <div key={key}>
                  <label className="block text-xs text-[#8b949e] mb-1">{label}</label>
                  <input type={type} value={form[key]} onChange={e => setForm({...form,[key]:e.target.value})}
                    className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]"
                    required={key !== 'bio'}/>
                </div>
              ))}
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowModal(false)} className="flex-1 py-2 text-sm border border-[#2d333b] rounded-md text-[#8b949e] hover:bg-[#21262d] transition-colors">Cancel</button>
                <button type="submit" className="flex-1 py-2 text-sm bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] rounded-md hover:bg-opacity-20 transition-colors">Create</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Service Modal */}
      {showServiceModal && selectedProvider && (
        <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50">
          <div className="bg-[#161b22] border border-[#2d333b] rounded-lg p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-1">
              <h2 className="text-base font-semibold text-[#cdd9e5]">Assign Service</h2>
              <button onClick={() => setShowServiceModal(false)} className="text-[#8b949e] hover:text-[#cdd9e5]"><X size={16}/></button>
            </div>
            <p className="text-xs text-[#8b949e] mb-4">Adding service to <span className="text-[#20c9c9]">{selectedProvider.fullName}</span></p>
            <form onSubmit={handleAddService} className="space-y-4">
              <div>
                <label className="block text-xs text-[#8b949e] mb-1">Select Service</label>
                <select value={serviceForm.serviceId} onChange={e => setServiceForm({...serviceForm, serviceId: e.target.value})}
                  className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]"
                  required>
                  <option value="">Choose a service...</option>
                  {services.map(s => (
                    <option key={s.id} value={s.id}>{s.category.icon} {s.name} — base ${s.basePrice}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-xs text-[#8b949e] mb-1">Provider Price ($)</label>
                <input type="number" value={serviceForm.price} onChange={e => setServiceForm({...serviceForm, price: e.target.value})}
                  placeholder="Enter price for this provider"
                  className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]"
                  required/>
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowServiceModal(false)} className="flex-1 py-2 text-sm border border-[#2d333b] rounded-md text-[#8b949e] hover:bg-[#21262d] transition-colors">Cancel</button>
                <button type="submit" className="flex-1 py-2 text-sm bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] rounded-md hover:bg-opacity-20 transition-colors">Assign Service</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}