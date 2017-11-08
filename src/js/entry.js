import setupLinkTracking from './services/link_track.js';
import setupForms from './components/slack_form.js';

window.addEventListener('DOMContentLoaded', () => {
  setupForms();
  setupLinkTracking(link => link.matches('.post-content a'));
});
