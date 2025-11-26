import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Home from './Home';

const Index = () => {
  const navigate = useNavigate();
  
  useEffect(() => {
    // Check if onboarding is complete
    const onboardingComplete = localStorage.getItem('onboarding_complete');
    if (!onboardingComplete) {
      navigate('/onboarding');
    }
  }, [navigate]);

  return <Home />;
};

export default Index;
