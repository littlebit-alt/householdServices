import { useEffect, useState } from 'react';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import api from '../services/api';
import toast from 'react-hot-toast';

export default function Services() {
  const [services, setServices] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ name: '', description: '', basePrice: '', categoryId: '' });

  const fetchData = async () => {
    try {
      const [sr, cr] = await Promise.all([api.get('/services'), api.get('/categories')]);
      setServices(sr.data.services); setCategories(cr.data.categories);
    } catch { toast.error('Failed'); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchData(); }, []);

  const openCreate = () => { setEditing(null); setForm({ name: '', description: '', basePrice: '', categoryId: '' }); setShowModal(true); };
  const openEdit = (s) => { setEditing(s); setForm({ name: s.name, description: s.description || '', basePrice: s.basePrice, categoryId: s.categoryId }); setShowModal(true); };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editing) { await api.put(`/services/${editing.id}`, form); toast.success('Updated!'); }
      else { await api.post('/services', form); toast.success('Created!'); }
      setShowModal(false); fetchData();
    } catch (err) { toast.error(err.response?.data?.message || 'Failed'); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete?')) return;
    try { await api.delete(`/services/${id}`); toast.success('Deleted'); fetchData(); }
    catch { toast.error('Failed'); }
  };

  return (
    <div className="p-6 space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-[#cdd9e5]">Services</h1>
          <p className="text-sm text-[#8b949e]">{services.length} services available</p>
        </div>
        <button onClick={openCreate} className="flex items-center gap-2 px-3 py-2 bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] text-sm rounded-md hover:bg-opacity-20 transition-colors">
          <Plus size={14}/> Add Service
        </button>
      </div>

      <div className="bg-[#161b22] border border-[#2d333b] rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#2d333b]">
              {['Name','Category','Base Price','Providers','Status','Actions'].map(h => (
                <th key={h} className="px-5 py-3 text-left text-xs font-medium text-[#8b949e] uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-[#21262d]">
            {loading && <tr><td colSpan={6} className="px-5 py-8 text-center"><div className="w-5 h-5 border-2 border-[#20c9c9] border-t-transparent rounded-full animate-spin mx-auto"/></td></tr>}
            {services.map(s => (
              <tr key={s.id} className="hover:bg-[#1c2128] transition-colors">
                <td className="px-5 py-3">
                  <p className="font-medium text-[#cdd9e5]">{s.name}</p>
                  <p className="text-xs text-[#8b949e]">{s.description}</p>
                </td>
                <td className="px-5 py-3">
                  <span className="text-xs px-2 py-1 rounded-full bg-[#2d333b] text-[#8b949e] border border-[#444c56]">
                    {s.category.icon} {s.category.name}
                  </span>
                </td>
                <td className="px-5 py-3 font-semibold text-[#20c9c9]">${s.basePrice}</td>
                <td className="px-5 py-3 text-[#cdd9e5]">{s._count.providers}</td>
                <td className="px-5 py-3">
                  <span className={`text-xs px-2 py-1 rounded-full border ${s.isActive ? 'bg-[#20c9c9] bg-opacity-10 text-[#20c9c9] border-[#20c9c9] border-opacity-20' : 'bg-red-400 bg-opacity-10 text-red-400 border-red-400 border-opacity-20'}`}>
                    {s.isActive ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-5 py-3">
                  <div className="flex items-center gap-2">
                    <button onClick={() => openEdit(s)} className="text-[#8b949e] hover:text-[#20c9c9] transition-colors"><Pencil size={14}/></button>
                    <button onClick={() => handleDelete(s.id)} className="text-[#8b949e] hover:text-red-400 transition-colors"><Trash2 size={14}/></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50">
          <div className="bg-[#161b22] border border-[#2d333b] rounded-lg p-6 w-full max-w-md">
            <h2 className="text-base font-semibold text-[#cdd9e5] mb-4">{editing ? 'Edit Service' : 'Add Service'}</h2>
            <form onSubmit={handleSubmit} className="space-y-3">
              <div>
                <label className="block text-xs text-[#8b949e] mb-1">Name</label>
                <input value={form.name} onChange={e => setForm({...form,name:e.target.value})} className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]" required/>
              </div>
              <div>
                <label className="block text-xs text-[#8b949e] mb-1">Description</label>
                <input value={form.description} onChange={e => setForm({...form,description:e.target.value})} className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]"/>
              </div>
              <div>
                <label className="block text-xs text-[#8b949e] mb-1">Base Price ($)</label>
                <input type="number" value={form.basePrice} onChange={e => setForm({...form,basePrice:e.target.value})} className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]" required/>
              </div>
              <div>
                <label className="block text-xs text-[#8b949e] mb-1">Category</label>
                <select value={form.categoryId} onChange={e => setForm({...form,categoryId:e.target.value})} className="w-full px-3 py-2 text-sm bg-[#0d1117] border border-[#2d333b] rounded-md text-[#cdd9e5] focus:outline-none focus:border-[#20c9c9]" required>
                  <option value="">Select category</option>
                  {categories.map(c => <option key={c.id} value={c.id}>{c.icon} {c.name}</option>)}
                </select>
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowModal(false)} className="flex-1 py-2 text-sm border border-[#2d333b] rounded-md text-[#8b949e] hover:bg-[#21262d] transition-colors">Cancel</button>
                <button type="submit" className="flex-1 py-2 text-sm bg-[#20c9c9] bg-opacity-10 border border-[#20c9c9] border-opacity-30 text-[#20c9c9] rounded-md hover:bg-opacity-20 transition-colors">{editing ? 'Update' : 'Create'}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}