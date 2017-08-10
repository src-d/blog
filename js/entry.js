import setupLinkTracking from './services/link_track.js';
import setupForms from './slack_form.js';

function isLinkInContent(link) {
  return link.matches('.post-content a');
}
window.addEventListener('DOMContentLoaded', () => {
  setupForms();
  setupLinkTracking(isLinkInContent);
});
