import React, { useState, useEffect } from 'react';
import { Destination, Report, LocalProvider, AdminAnalytics } from './types';
import { getDestinations, getReports, getProviders, getAdminAnalytics } from './services/api';
import { Navbar } from './components/layout/Navbar';
import { Sidebar } from './components/layout/Sidebar';
import { DashboardOverview } from './pages/DashboardOverview';
import { RegionalMapPage } from './pages/RegionalMapPage';
import { DestinationsPage } from './pages/DestinationsPage';
import { ReportsPage } from './pages/ReportsPage';
import { ProvidersPage } from './pages/ProvidersPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { TripPlannerDemo } from './pages/TripPlannerDemo';
import { PressureBreakdownModal } from './components/destinations/PressureBreakdownModal';

export const App: React.FC = () => {
  const [currentTab, setCurrentTab] = useState('overview');
  const [destinations, setDestinations] = useState<Destination[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [providers, setProviders] = useState<LocalProvider[]>([]);
  const [analytics, setAnalytics] = useState<AdminAnalytics | null>(null);
  const [selectedDestination, setSelectedDestination] = useState<Destination | null>(null);
  const [loading, setLoading] = useState(true);

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
    // Poll every 30 seconds for live updates
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  const handleReportUpdated = (updatedReport: Report) => {
    setReports((prev) => prev.map((r) => r.id === updatedReport.id ? updatedReport : r));
    getAdminAnalytics().then(setAnalytics).catch(() => {});
  };

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      <Navbar activeTab={currentTab} />

      <div style={{ display: 'flex', gap: '20px', padding: '0 24px 24px 24px', flex: 1 }}>
        <Sidebar
          currentTab={currentTab}
          onTabChange={setCurrentTab}
          openIssuesCount={reports.filter((r) => r.status !== 'RESOLVED').length}
        />

        <main style={{ flex: 1, minWidth: 0 }}>
          {currentTab === 'overview' && (
            <DashboardOverview
              analytics={analytics}
              destinations={destinations}
              reports={reports}
              providers={providers}
              onSelectDestination={setSelectedDestination}
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

          {currentTab === 'destinations' && (
            <DestinationsPage
              destinations={destinations}
              onSelectDestination={setSelectedDestination}
            />
          )}

          {currentTab === 'reports' && (
            <ReportsPage
              reports={reports}
              onReportUpdated={handleReportUpdated}
            />
          )}

          {currentTab === 'providers' && (
            <ProvidersPage
              providers={providers}
            />
          )}

          {currentTab === 'analytics' && (
            <AnalyticsPage
              analytics={analytics}
            />
          )}

          {currentTab === 'planner_demo' && (
            <TripPlannerDemo />
          )}
        </main>
      </div>

      {/* Destination Pressure Breakdown Modal */}
      {selectedDestination && (
        <PressureBreakdownModal
          destination={selectedDestination}
          onClose={() => setSelectedDestination(null)}
        />
      )}
    </div>
  );
};

export default App;
