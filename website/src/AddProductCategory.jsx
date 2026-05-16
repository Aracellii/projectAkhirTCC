import { useState } from 'react';
import './AddProductCategory.css';

export default function AddProductCategory({ onCategoryAdded }) {
  const [formData, setFormData] = useState({ name: '', credit_per_kg: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const API_BASE_URL = 'http://localhost:5000/api/v1';

  const getAuthHeader = () => {
    const token = localStorage.getItem('token');
    return { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' };
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name) {
      setError('Nama kategori harus diisi');
      return;
    }
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/categories`, {
        method: 'POST',
        headers: getAuthHeader(),
        body: JSON.stringify({
          name: formData.name,
          credit_per_kg: formData.credit_per_kg ? parseInt(formData.credit_per_kg) : 0
        })
      });
      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || 'Gagal menyimpan kategori');
      }
      setFormData({ name: '', credit_per_kg: '' });
      onCategoryAdded();
    } catch (err) {
      setError(err.message || 'Terjadi kesalahan');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="form-field">
        <label htmlFor="cat-name">Nama Kategori *</label>
        <input
          type="text"
          id="cat-name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-field">
        <label htmlFor="cat-credit">Kredit per kg</label>
        <input
          type="number"
          id="cat-credit"
          name="credit_per_kg"
          value={formData.credit_per_kg}
          onChange={handleChange}
          min="0"
        />
  
      </div>

      {error && (
        <div className="field-error">
          <span>⚠️</span>
          {error}
        </div>
      )}

      <button type="submit" className="form-submit-btn" disabled={loading}>
        {loading ? (
          <>
            <span className="btn-mini-spinner" />
            Menyimpan...
          </>
        ) : (
          '+ Tambah Kategori'
        )}
      </button>
    </form>
  );
}