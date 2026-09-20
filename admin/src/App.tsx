import React, { useState, useEffect } from 'react';
import { Destination, Report, LocalProvider, AdminAnalytics } from './types';
import { getDestinations, getReports, getProviders, getAdminAnalytics } from './services/api';
import { useAuth, AuthProvider } from './context/AuthContext';
import { Navbar } from './components/layout/Navbar';
import { Sidebar } from './components/layout/Sidebar';
import { LoginPage } from './components/auth/LoginPage';
import { DashboardOverview } from './pages/DashboardOverview';
import { RegionalMapPage } from './pages/RegionalMapPage';
import { PressureHeatmapPage } from './pages/PressureHeatmapPage';
import { DestinationsPage } from './pages/DestinationsPage';
import { PressureTrendsPage } from './pages/PressureTrendsPage';
import { PressurePredictionsPage } from './pages/PressurePredictionsPage';
import { ReportsPage } from './pages/ReportsPage';
import { ProvidersPage } from './pages/ProvidersPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { SettingsPage } from './pages/SettingsPage';
import { TripPlannerDemo } from './pages/TripPlannerDemo';
import { NotificationsPage } from './pages/NotificationsPage';

// Modals
import { DestinationDetailModal } from './components/destinations/DestinationDetailModal';
import { DestinationEditModal } from './components/destinations/DestinationEditModal';
import { ReportDetailModal } from './components/reports/ReportDetailModal';
import { ProviderDetailModal } from './components/providers/ProviderDetailModal';
import { ProviderEditModal } from './components/providers/ProviderEditModal';

const AdminPortalContent: React.FC = () => {
  const { token, role, loading: authLoading } = useAuth();

  const [currentTab, setCurrentTab] = useState('overview');
  const [destinations, setDestinations] = useState<Destination[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [providers, setProviders] = useState<LocalProvider[]>([]);
  const [analytics, setAnalytics] = useState<AdminAnalytics | null>(null);
  const [loading, setLoading] = useState(true);

  // Modal States
  const [selectedDestination, setSelectedDestination] = useState<Destination | null>(null);
  const [editingDestination, setEditingDestination] = useState<Destination | null | 'NEW'>(null);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [selectedProvider, setSelectedProvider] = useState<LocalProvider | null>(null);
  const [editingProvider, setEditingProvider] = useState<LocalProvider | null | 'NEW'>(null);

  const fetchData = async () => {
    try {
      const [dests, reps, provs, anal] = await Promise.allSettled([
        getDestinations(),
        getReports(),
        getProviders(),
        getAdminAnalytics()
      ]);

      if (dests.status === 'fulfilled') setDestinations(dests.value);
      if (reps.status === 'fulfilled') setReports(reps.value);
      if (provs.status === 'fulfilled') setProviders(provs.value);
      if (anal.status === 'fulfilled') setAnalytics(anal.value);
    } catch (err) {
      console.error('Error fetching admin data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    // Live Telemetry Sync every 25 seconds
    const interval = setInterval(fetchData, 25000);
    return () => clearInterval(interval);
  }, []);

  // Handlers for real-time updates
  const handleReportUpdated = (updated: Report) => {
    setReports((prev) => prev.map((r) => r.id === updated.id ? updated : r));
    getAdminAnalytics().then(setAnalytics).catch(() => {});
  };

  const handleDestinationSaved = (saved: Destination) => {
    setDestinations((prev) => {
      const exists = prev.some((d) => d.id === saved.id);
      if (exists) {
        return prev.map((d) => d.id === saved.id ? saved : d);
      }
      return [saved, ...prev];
    });
    getAdminAnalytics().then(setAnalytics).catch(() => {});
  };

  const handleProviderSaved = (saved: LocalProvider) => {
    setProviders((prev) => {
      const exists = prev.some((p) => p.id === saved.id);
      if (exists) {
        return prev.map((p) => p.id === saved.id ? saved : p);
      }
      return [saved, ...prev];
    });
    getAdminAnalytics().then(setAnalytics).catch(() => {});
  };

  const handleProviderDeleted = (id: string) => {
    setProviders((prev) => prev.filter((p) => p.id !== id));
    getAdminAnalytics().then(setAnalytics).catch(() => {});
  };

  // If not authenticated or token missing, show login page
  if (!token) {
    return <LoginPage onSuccess={fetchData} />;
  }

  const openIssuesCount = reports.filter((r) => r.status !== 'RESOLVED').length;

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      <Navbar activeTab={currentTab} onNavigateTab={setCurrentTab} />

      <div style={{ display: 'flex', gap: '20px', padding: '0 24px 24px 24px', flex: 1 }}>
        <Sidebar
          currentTab={currentTab}
          onTabChange={setCurrentTab}
          openIssuesCount={openIssuesCount}
        />

        <main style={{ flex: 1, minWidth: 0 }}>
          {currentTab === 'overview' && (
            <DashboardOverview
              analytics={analytics}
              destinations={destinations}
              reports={reports}
              providers={providers}
              onSelectDestination={setSelectedDestination}
              onSelectReport={setSelectedReport}
              onNavigateTab={setCurrentTab}
            />
          )}

          {currentTab === 'map' && (
            <RegionalMapPage
              destinations={destinations}
              reports={reports}
              providers={providers}
              onSelectDestination={setSelectedDestination}
            />
          )}

          {currentTab === 'heatmap' && (
            <PressureHeatmapPage
              destinations={destinations}
              onSelectDestination={setSelectedDestination}
            />
          )}

          {currentTab === 'destinations' && (
            <DestinationsPage
              destinations={destinations}
              onSelectDestination={setSelectedDestination}
              onAddDestination={() => setEditingDestination('NEW')}
              onEditDestination={(d) => setEditingDestination(d)}
            />
          )}

          {currentTab === 'trends' && (
            <PressureTrendsPage
              destinations={destinations}
              onSelectDestination={setSelectedDestination}
            />
          )}

          {currentTab === 'predictions' && (
            <PressurePredictionsPage
              destinations={destinations}
              onSelectDestination={setSelectedDestination}
            />
          )}

          {currentTab === 'reports' && (
            <ReportsPage
              reports={reports}
              onReportUpdated={handleReportUpdated}
              selectedReport={selectedReport}
              onClearSelectedReport={() => setSelectedReport(null)}
            />
          )}

          {currentTab === 'providers' && (
            <ProvidersPage
              providers={providers}
              destinations={destinations}
              onSelectProvider={setSelectedProvider}
              onAddProvider={() => setEditingProvider('NEW')}
              onEditProvider={(p) => setEditingProvider(p)}
            />
          )}

          {currentTab === 'analytics' && (
            <AnalyticsPage
              analytics={analytics}
            />
          )}

          {currentTab === 'settings' && (
            <SettingsPage />
          )}

          {currentTab === 'planner_demo' && (
            <TripPlannerDemo />
          )}

          {currentTab === 'notifications' && (
            <NotificationsPage
              onInspectDestination={(id) => {
                const found = destinations.find(d => d.id === id);
                if (found) setSelectedDestination(found);
              }}
              onInspectReport={(id) => {
                const found = reports.find(r => r.id === id);
                if (found) setSelectedReport(found);
                else setCurrentTab('reports');
              }}
            />
          )}
        </main>
      </div>

      {/* 1. Destination Details Modal */}
      {selectedDestination && (
        <DestinationDetailModal
          destination={selectedDestination}
          onClose={() => setSelectedDestination(null)}
          onEdit={(d) => {
            setSelectedDestination(null);
            setEditingDestination(d);
          }}
        />
      )}

      {/* 2. Destination Edit / Create Modal */}
      {editingDestination && (
        <DestinationEditModal
          destination={editingDestination === 'NEW' ? null : editingDestination}
          onClose={() => setEditingDestination(null)}
          onSaved={handleDestinationSaved}
        />
      )}

      {/* 3. Report Detail / Triage Modal */}
      {selectedReport && (
        <ReportDetailModal
          report={selectedReport}
          onClose={() => setSelectedReport(null)}
          onUpdated={(updated) => {
            handleReportUpdated(updated);
            setSelectedReport(null);
          }}
        />
      )}

      {/* 4. Provider Details Modal */}
      {selectedProvider && (
        <ProviderDetailModal
          provider={selectedProvider}
          onClose={() => setSelectedProvider(null)}
          onEdit={(p) => {
            setSelectedProvider(null);
            setEditingProvider(p);
          }}
        />
      )}

      {/* 5. Provider Edit / Create Modal */}
      {editingProvider && (
        <ProviderEditModal
          provider={editingProvider === 'NEW' ? null : editingProvider}
          destinations={destinations}
          onClose={() => setEditingProvider(null)}
          onSaved={handleProviderSaved}
          onDeleted={handleProviderDeleted}
        />
      )}
    </div>
  );
};

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <AdminPortalContent />
    </AuthProvider>
  );
};

export default App;
