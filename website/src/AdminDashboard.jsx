import { useState, useEffect } from 'react';
import AddDonationLocation from './AddDonationLocation';
import AddProductCategory from './AddProductCategory';
import './AdminDashboard.css';

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('donation-location');
  const [locations, setLocations] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const API_BASE_URL = 'http://localhost:5000/api/v1';

  const username = localStorage.getItem('username') || 'Admin';

  const getAuthHeader = () => {
    const token = localStorage.getItem('token');
    return {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
  };

  const fetchDonationLocations = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/donation-locations`);
      if (!response.ok) throw new Error('Failed to fetch locations');
      const data = await response.json();
      setLocations(data);
    } catch (error) {
      console.error('Error fetching locations:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchCategories = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/categories`, { headers: getAuthHeader() });
      if (!response.ok) throw new Error('Failed to fetch categories');
      const data = await response.json();
      setCategories(data);
    } catch (error) {
      console.error('Error fetching categories:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'donation-location') fetchDonationLocations();
    else if (activeTab === 'product-category') fetchCategories();
  }, [activeTab]);

  const handleDeleteLocation = async (id) => {
    if (!window.confirm('Yakin ingin menghapus lokasi donasi ini?')) return;
    try {
      const response = await fetch(`${API_BASE_URL}/donation-locations/${id}`, {
        method: 'DELETE',
        headers: getAuthHeader()
      });
      if (!response.ok) throw new Error('Failed to delete');
      fetchDonationLocations();
    } catch (error) {
      console.error('Error deleting location:', error);
    }
  };

  const tabs = [
    { id: 'donation-location', label: 'Lokasi Donasi'},
    { id: 'product-category', label: 'Kategori Produk'},
  ];

  const pageInfo = {
    'donation-location': { title: 'Lokasi Donasi', subtitle: 'Kelola titik pengumpulan sampah dan drop point' },
    'product-category': { title: 'Kategori Produk', subtitle: 'Atur kategori produk daur ulang dan nilai kredit' },
  };

  return (
    <div className="admin-layout">
      {/* Sidebar */}
      <aside className="admin-sidebar">
        <div className="sidebar-header">
          <div className="sidebar-logo">
            <div className="sidebar-logo-icon">♻️</div>
            <span className="sidebar-logo-text">Waste<span>Pro</span></span>
          </div>
        </div>

        <nav className="sidebar-nav">
          <span className="sidebar-section-label">Menu</span>
          {tabs.map(tab => (
            <button
              key={tab.id}
              className={`nav-item ${activeTab === tab.id ? 'active' : ''}`}
              onClick={() => setActiveTab(tab.id)}
            >
              <span className="nav-item-icon">{tab.icon}</span>
              {tab.label}
            </button>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="sidebar-user">
            <div className="sidebar-user-avatar">👤</div>
            <div className="sidebar-user-info">
              <span className="sidebar-user-name">{username}</span>
              <span className="sidebar-user-role">Administrator</span>
            </div>
          </div>
        </div>
      </aside>

      {/* Main */}
      <div className="admin-main">
        {/* Topbar */}
        <header className="admin-topbar">
          <div className="topbar-breadcrumb">
            <span className="breadcrumb-home">Dashboard</span>
            <span className="breadcrumb-sep">›</span>
            <span className="breadcrumb-current">{pageInfo[activeTab].title}</span>
          </div>
          <div className="topbar-actions">
            <div className="topbar-badge">
              <span className="topbar-badge-dot" />
              Sistem Aktif
            </div>
          </div>
        </header>

        {/* Content */}
        <main className="admin-content">
          <div className="page-header">
            <h1 className="page-title">{pageInfo[activeTab].title}</h1>
            <p className="page-subtitle">{pageInfo[activeTab].subtitle}</p>
          </div>

          {/* Donation Locations */}
          {activeTab === 'donation-location' && (
            <div className="content-grid">
              <div className="card">
                <div className="card-header">
                  <span className="card-title">Tambah Lokasi Baru</span>
                </div>
                <div className="card-body">
                  <AddDonationLocation onLocationAdded={fetchDonationLocations} />
                </div>
              </div>

              <div className="card">
                <div className="card-header">
                  <span className="card-title">Daftar Lokasi</span>
                  <span className="card-count">{locations.length} lokasi</span>
                </div>
                <div className="card-body">
                  {loading ? (
                    <div className="loading-state">
                      <div className="loading-spinner" />
                      <span className="loading-text">Memuat data...</span>
                    </div>
                  ) : locations.length === 0 ? (
                    <div className="empty-state">
                      <div className="empty-icon"></div>
                      <p className="empty-title">Belum ada lokasi</p>
                      <p className="empty-desc">Tambahkan lokasi donasi pertama Anda</p>
                    </div>
                  ) : (
                    <div className="items-list">
                      {locations.map(loc => (
                        <div key={loc.id} className="item-card">
                          <div className="item-card-header">
                            <span className="item-name">{loc.name}</span>
                            <span className={`item-badge ${loc.is_active ? 'badge-active' : 'badge-inactive'}`}>
                              {loc.is_active ? '● Aktif' : '● Nonaktif'}
                            </span>
                          </div>
                          <div className="item-detail">
                            <span className="item-detail-icon"></span>
                            {loc.address}
                          </div>
                          <div className="item-detail">
                            <span className="item-detail-icon"></span>
                            {loc.city}
                          </div>
                          {loc.latitude && loc.longitude && (
                            <div className="item-coord">
                              {loc.latitude}, {loc.longitude}
                            </div>
                          )}
                          <div className="item-footer">
                            <button className="btn-delete" onClick={() => handleDeleteLocation(loc.id)}>
                              🗑️ Hapus
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Product Categories */}
          {activeTab === 'product-category' && (
            <div className="content-grid">
              <div className="card">
                <div className="card-header">
                  <span className="card-title">Tambah Kategori Baru</span>
                </div>
                <div className="card-body">
                  <AddProductCategory onCategoryAdded={fetchCategories} />
                </div>
              </div>

              <div className="card">
                <div className="card-header">
                  <span className="card-title">Daftar Kategori</span>
                  <span className="card-count">{categories.length} kategori</span>
                </div>
                <div className="card-body">
                  {loading ? (
                    <div className="loading-state">
                      <div className="loading-spinner" />
                      <span className="loading-text">Memuat data...</span>
                    </div>
                  ) : categories.length === 0 ? (
                    <div className="empty-state">
                      <div className="empty-icon">🗂️</div>
                      <p className="empty-title">Belum ada kategori</p>
                      <p className="empty-desc">Tambahkan kategori produk daur ulang</p>
                    </div>
                  ) : (
                    <div className="items-list">
                      {categories.map(cat => (
                        <div key={cat.id} className="item-card">
                          <div className="item-card-header">
                            <span className="item-name">{cat.name}</span>
                          </div>
                          <div className="category-credits">
                            <div className="credit-pill">
                              <span className="credit-icon"></span>
                              {cat.credit_per_kg} kredit / kg
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}
        </main>
      </div>
    </div>
  );
}