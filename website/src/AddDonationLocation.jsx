import { useState } from 'react';
import './AddDonationLocation.css';

export default function AddDonationLocation({ onLocationAdded }) {
  const [formData, setFormData] = useState({
    name: '', address: '', city: '', latitude: '', longitude: '', is_active: true
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const API_BASE_URL = 'http://localhost:5000/api/v1';

  const getAuthHeader = () => {
    const token = localStorage.getItem('token');
    return { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' };
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({ ...prev, [name]: type === 'checkbox' ? checked : value }));
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name || !formData.address || !formData.city) {
      setError('Nama, alamat, dan kota harus diisi');
      return;
    }
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/donation-locations`, {
        method: 'POST',
        headers: getAuthHeader(),
        body: JSON.stringify({
          name: formData.name,
          address: formData.address,
          city: formData.city,
          latitude: formData.latitude ? parseFloat(formData.latitude) : null,
          longitude: formData.longitude ? parseFloat(formData.longitude) : null,
          is_active: formData.is_active
        })
      });
      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || 'Gagal menyimpan lokasi donasi');
      }
      setFormData({ name: '', address: '', city: '', latitude: '', longitude: '', is_active: true });
      onLocationAdded();
    } catch (err) {
      setError(err.message || 'Terjadi kesalahan');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="form-field">
        <label htmlFor="loc-name">Nama Lokasi *</label>
        <input
          type="text"
          id="loc-name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-field">
        <label htmlFor="loc-address">Alamat *</label>
        <textarea
          id="loc-address"
          name="address"
          value={formData.address}
          onChange={handleChange}
          rows="2"
          required
        />
      </div>

      <div className="form-row">
        <div className="form-field">
          <label htmlFor="loc-city">Kota *</label>
          <input
            type="text"
            id="loc-city"
            name="city"
            value={formData.city}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-field">
          <label htmlFor="loc-lat">Latitude</label>
          <input
            type="number"
            id="loc-lat"
            name="latitude"
            value={formData.latitude}
            onChange={handleChange}
            step="0.0000001"
          />
        </div>
        <div className="form-field">
          <label htmlFor="loc-lng">Longitude</label>
          <input
            type="number"
            id="loc-lng"
            name="longitude"
            value={formData.longitude}
            onChange={handleChange}
            step="0.0000001"
          />
        </div>
      </div>

      <div className="form-field is-checkbox">
        <input
          type="checkbox"
          id="loc-active"
          name="is_active"
          checked={formData.is_active}
          onChange={handleChange}
        />
        <label htmlFor="loc-active">Lokasi aktif dan dapat menerima donasi</label>
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
          '+ Tambah Lokasi'
        )}
      </button>
    </form>
  );
}