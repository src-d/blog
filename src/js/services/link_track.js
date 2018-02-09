/* eslint-env browser */
import $ from 'jquery';

const SEND_COMMAND = 'send';
const EVENT_HIT_TYPE = 'event';
const EVENT_FIELDS = ['eventCategory', 'eventAction', 'eventLabel', 'eventValue', 'transport', 'hitCallback'];

/**
 * Compulsory fields for send event on clicking a link.
 */
function compulsoryFields(/* link */) {
  return {
    transport: 'beacon',
  };
}

/**
 * Returns the URL origin given a string representation of it. If the browser
 * does not support URL, it returns href itself.
 *
 * @param {String} href the string containing the URL.
 * @return {String} the origin of the URL.
 */
function getOrigin(href) {
  if (URL !== undefined) {
    return new URL(href).origin;
  }

  return href;
}

/**
 * Computes the default values for some keys to the send event command.
 *
 * @param {HTMLAnchorElement} link anchor clicked.
 * @return {Object} object with the default values.
 */
function defaultsForLink(link) {
  const sameOrigin = getOrigin(link) === window.location.origin;
  return {
    eventCategory: sameOrigin ? 'inbound' : 'outbound',
    eventAction: 'click',
    eventLabel: link.href,
  };
}

/**
 * Computes the data for a given anchor element
 *
 * @param {HTMLAnchorElement} link
 * @return {Object} object with the values to call ga send event command.
 */
function getData(link) {
  const data = Object.assign(
    defaultsForLink(link),
    link.dataset,
    compulsoryFields(link),
  );

  return EVENT_FIELDS.reduce((memo, key) => {
    /* eslint no-param-reassign: ["error", { "props": false }] */
    if (key in data) {
      memo[key] = data[key];
    }
    return memo;
  }, {});
}

/**
 * Returns the arguments to call ga command when the link has been clicked.
 *
 * @param {HTMLAnchorElement} link element to get the data from.
 * @return {Array<String, String, Object>} arguments for ga method.
 */
function commandArguments(link) {
  return [SEND_COMMAND, EVENT_HIT_TYPE, getData(link)];
}

// If ga is not installed, we have a fallback that both stores and logs the
// call.
const gaInternal = [];
const ga = window.ga || function (...args) {
  gaInternal.push(args);
  // eslint-disable-next-line no-console
  console.log(...args);

  const last = args.pop();

  if (typeof last.hitCallback === 'function') {
    setTimeout(last.hitCallback.bind(last), 0);
  }
};

/**
 * Promisify ga
 *
 * @param {...any} args
 * @return {Promise} a promise that resolves whenever the hitCallback is called.
 */
export function gaPromise(...args) {
  let obj = {};
  let oldCallback = () => { };

  if (typeof args[args.length - 1] === 'object') {
    obj = args.pop();
  }

  if (typeof obj.hitCallback === 'function') {
    oldCallback = obj.hitCallback;
  }

  return new Promise((resolve) => {
    obj.hitCallback = (...cbArgs) => {
      oldCallback(...cbArgs);
      resolve(...cbArgs);
    };
    ga(...args, obj);
  });
}

export function isScrollableLink(link) {
  const [url, id] = link.href.split('#');

  return window.location.href.indexOf(url) >= 0 && id;
}

/**
 * Scrolls to element anchored by the given link.
 *
 * @param {HTMLAnchorElement} link
 */
export function scrollTo(link) {
  const [, id] = link.href.split('#');
  $('body, html').animate(
    {
      scrollTop: $(`#${id}`).offset().top,
    },
    1000,
  );
}

/**
 * Same as window.setTimeout, but as a promise.
 *
 * @param {Number} ms
 */
function setTimeoutPromise(ms) {
  return new Promise(resolve => window.setTimeout(resolve, ms));
}

/**
 * Sends to Google Analytics the details from the link
 *
 * @param {HTMLAnchorElement} link anchor clicked
 * @return {Promise} a promise resolved whenever hitCallback is called.
 */
export function sendLinkDetails(link, ms = 500) {
  return Promise.race([
    setTimeoutPromise(ms),
    gaPromise(...commandArguments(link)),
  ]);
}

/**
 * Emulates the click on the link.
 *
 * @param {HTMLAnchorElement} link anchor to emulate
 */
export function goToLink(link, evt) {
  if (link.target === '_blank'  // link to _blank
    || evt.metaKey              // command key
    || evt.shiftKey             // shift key
    || evt.ctrlKey              // control key
    || evt.button === 1) {      // middle button click
    window.open(link.href, '_blank');
  } else {
    window.location.href = link.href;
  }
}

function trackableLink({ dataset, href }) {
  return 'tracked' in dataset && href;
}

/**
 * Sets up the tracking of links, inbound and outbound.
 *
 * For a link to be tracked it needs to:
 *
 * 1. Have a `data-tracked` attribute.
 * 2. Have a non-empty `href` attribute.
 *
 * Or satisfy the acceptableCondition predicate.
 */
export default function setupLinkTracking(acceptableCondition = () => false) {
  document.addEventListener('click', (evt) => {
    const { target } = evt;
    if (!(trackableLink(target) || acceptableCondition(target))) {
      return;
    }

    evt.preventDefault();

    if (isScrollableLink(target)) {
      sendLinkDetails(target);
      scrollTo(target);
      return;
    }

    sendLinkDetails(target)
      .then(() => goToLink(target, evt));
  });
}
