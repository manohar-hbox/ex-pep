// Helper JavaScript for making Twilio calls work properly
(function() {
  // First create the twilioHelper object if it doesn't exist
  window.twilioHelper = {};

  // Define error handler to improve diagnostics
  function handleTwilioError(functionName, error) {
    console.error(`Error in Twilio ${functionName}:`, error);
    console.error(`Stack trace:`, error.stack);
    return false; // Always return a definite value on error
  }

  // Add window close protection handler
  window.twilioHelper.enableCloseProtection = function(enable) {
    if (enable) {
      window.onbeforeunload = function(e) {
        // Check if call is in progress
        if (window._currentCall) {
          console.log('Close protection triggered - active call detected');
          // Standard message for beforeunload (browsers will use their own message)
          const message = 'You have an active call in progress. Are you sure you want to leave?';
          e.preventDefault();
          e.returnValue = message;
          return message;
        }
      };
      console.log('Close protection enabled');
    } else {
      window.onbeforeunload = null;
      console.log('Close protection disabled');
    }
  };

  // Store incoming call reference
  window._incomingCall = null;

  // Function to load the Twilio SDK
  function loadTwilioSDK() {
    return new Promise((resolve, reject) => {
      // Check if already loaded
      if (window.Twilio && window.Twilio.Device) {
        console.log("Twilio SDK already loaded");
        resolve(true);
        return;
      }

      console.log("Loading Twilio SDK...");
      const script = document.createElement('script');
      script.src = 'https://sdk.twilio.com/js/client/releases/1.14.0/twilio.js';
      script.async = true;
      script.onload = () => {
        console.log("Twilio SDK loaded successfully");
        resolve(true);
      };
      script.onerror = (error) => {
        console.error("Failed to load Twilio SDK:", error);
        reject(error);
      };
      document.head.appendChild(script);
    });
  }

  // Define setupTwilio with proper error handling
  window.twilioHelper.setupTwilio = function(token) {
    try {
      // Ensure token is a string, default to empty string if null/undefined
      if (token === null || token === undefined) {
        console.log('setupTwilio called with null/undefined token, using empty string');
        token = '';
      }

      console.log('setupTwilio called with token:', token ? (token.substring(0, 5) + '...') : '[empty]');

      // Return a promise that resolves when Twilio is ready
      return new Promise((resolve, reject) => {
        // First load the SDK if needed
        loadTwilioSDK()
          .then(() => {
            // Check if Twilio SDK is available
            if (window.Twilio && window.Twilio.Device) {
              try {
                window._twilioDevice = new window.Twilio.Device(token, {
                  codecPreferences: ['opus', 'pcmu'],
                  fakeLocalDTMF: true,
                  enableRingingState: true,
                  closeProtection: true,
                  debug: true
                });
                console.log('Created Twilio.Device successfully!');

                // Enable close protection for all calls
                window.twilioHelper.enableCloseProtection(true);

                // Set up listeners for incoming calls
                _setupIncomingCallHandlers();

                resolve(true);
              } catch (e) {
                console.error('Error creating Twilio.Device:', e);
                // Resolve with true anyway to continue with stub implementation
                resolve(true);
              }
            } else {
              console.warn('Twilio SDK not available after loading attempt, using stub implementation');
              resolve(true);
            }
          })
          .catch(error => {
            console.error('Failed to load Twilio SDK:', error);
            // Resolve with true anyway to allow the UI to proceed
            resolve(true);
          });
      });
    } catch (e) {
      console.error('Exception in setupTwilio:', e);
      // Return a resolved promise to avoid breaking the calling code
      return Promise.resolve(true);
    }
  };

  // Set up handlers for incoming calls
  function _setupIncomingCallHandlers() {
    if (!window._twilioDevice) {
      console.warn('Cannot set up incoming call handlers: Twilio Device not initialized');
      return;
    }

    try {
      // Handle incoming calls
      window._twilioDevice.on('incoming', function(call) {
        console.log('Incoming call received:', call);

        // Store the call reference
        window._incomingCall = call;

        // Extract call details
        const callInfo = {
          from: call.parameters.From || 'Unknown Caller',
          to: call.parameters.To || 'Unknown',
          callerId: call.parameters.CallerId || call.parameters.From || 'Unknown',
          callSid: call.parameters.CallSid || '',
          parameters: call.parameters.Params || {},
        };
        console.log('Incoming call info:', callInfo);
        // Dispatch event to notify Flutter app of incoming call
        const incomingCallEvent = new CustomEvent('twilioIncomingCall', {
          detail: callInfo
        });
        document.dispatchEvent(incomingCallEvent);        // Try direct call to Dart with retry mechanism and ready event handling
        let dartHandlerReady = false;

        // Listen for Dart handler ready event
        document.addEventListener('dartTwilioHandlerReady', function() {
          console.log('Dart handler ready event received');
          dartHandlerReady = true;
        });

        const tryDartHandler = (retries = 10, delay = 300) => {
          try {
            if (window.DartTwilioHandler && window.DartTwilioHandler.handleIncomingCall) {
              console.log('Calling Dart handler directly...');
              // Convert parameters object to JSON string to prevent type mismatch
              const parametersString = JSON.stringify(callInfo.parameters || {});
              window.DartTwilioHandler.handleIncomingCall(
                callInfo.from,
                callInfo.to,
                callInfo.callerId,
                callInfo.callSid,
                parametersString
              );
              return true;
            } else if (retries > 0) {
              console.log(`DartTwilioHandler not available yet, retrying in ${delay}ms (${retries} retries left)`);
              // Check if we know handler is ready but just not visible
              if (dartHandlerReady) {
                console.log('Dart handler reported ready but not accessible - forcing check');
                delay = 100; // Shorter delay if we know it should be ready
              }
              setTimeout(() => tryDartHandler(retries - 1, delay), delay);
              return false;
            } else {
              console.log('DartTwilioHandler not available after all retries, relying on event only');
              return false;
            }
          } catch (e) {
            console.error('Error calling DartTwilioHandler:', e);
            if (retries > 0) {
              setTimeout(() => tryDartHandler(retries - 1, delay), delay);
            }
            return false;
          }
        };

        // Start the retry mechanism
        tryDartHandler();

        // Set up call-specific event handlers
        call.on('accept', function() {
          console.log('Call accepted');
          window._currentCall = call; // Set as current call

          // Dispatch event that call was accepted
          const acceptEvent = new CustomEvent('twilioCallAccepted');
          document.dispatchEvent(acceptEvent);
        });

        call.on('reject', function() {
          console.log('Call rejected');
          window._incomingCall = null;

          // Dispatch event that call was rejected
          const rejectEvent = new CustomEvent('twilioCallRejected');
          document.dispatchEvent(rejectEvent);
        });        call.on('cancel', function() {
          console.log('Call cancelled by caller');
          
          // Check if there's still an active call connection before dispatching cancel event
          const hasActiveConnection = (window._currentCall && 
            (window._currentCall.status === 'open' || window._currentCall.status === 'connecting'));
          
          if (hasActiveConnection) {
            console.log('NOT dispatching cancel event - active call connection detected');
            console.log('Current call status:', window._currentCall.status);
            return;
          }
          
          window._incomingCall = null;

          // Add debouncing to prevent multiple rapid cancel events
          if (window._lastCancelEventTime && (Date.now() - window._lastCancelEventTime) < 1000) {
            console.log('Debouncing cancel event - too soon after last cancel event');
            return;
          }
          window._lastCancelEventTime = Date.now();

          // Dispatch event that call was cancelled
          const cancelEvent = new CustomEvent('twilioCallCancelled');
          document.dispatchEvent(cancelEvent);

				  // Also try to call Dart handler directly for better reliability
				  try {
				    if (window.DartTwilioHandler && typeof window.DartTwilioHandler.handleCallCancelled === 'function') {
				      console.log('Calling Dart handler directly for call cancellation');
				      window.DartTwilioHandler.handleCallCancelled();
				    }
				  } catch (e) {
				    console.error('Error calling Dart cancel handler:', e);
				  }
        });

        call.on('disconnect', function() {
          console.log('Call disconnected');
          if (window._incomingCall === call) {
            window._incomingCall = null;
          }
          if (window._currentCall === call) {
            window._currentCall = null;
          }

          // Dispatch event that call was disconnected
          const disconnectEvent = new CustomEvent('twilioCallDisconnected');
          document.dispatchEvent(disconnectEvent);
        });
      });

      console.log('Incoming call handlers set up successfully');
    } catch (e) {
      console.error('Error setting up incoming call handlers:', e);
    }
  }

  // Store the CallSid for later use - make it persistent across browser tabs
//  window._storedCallSid = '';

  // Try to retrieve from localStorage if available
//  try {
//    const storedSid = localStorage.getItem('twilioCallSid');
//    if (storedSid) {
//      window._storedCallSid = storedSid;
//      console.log('Retrieved CallSid from localStorage:', window._storedCallSid);
//    }
//  } catch (e) {
//    console.error('Error accessing localStorage:', e);
//  }

  // Define makeCall with proper error handling
  window.twilioHelper.makeCall = function(toPhoneNumber, fromPhoneNumber, clinicId, callerId, originNumberType, patientId) {
    try {
      console.log('makeCall called with FROM Phone Number:', fromPhoneNumber);
      console.log('makeCall called with TO Phone Number:', toPhoneNumber);
      console.log('Twilio Device:', window._twilioDevice);

      // Reset the stored CallSid when making a new call
      window._storedCallSid = '';
      try {
        localStorage.removeItem('twilioCallSid');
      } catch (e) {
        console.error('Error clearing localStorage:', e);
      }

      // Ensure close protection is enabled when making a call
      window.twilioHelper.enableCloseProtection(true);

      // Try to use real Twilio Device if available
      if (window._twilioDevice) {
        try {
          window._currentCall = window._twilioDevice.connect({
            to: toPhoneNumber,
            pepPatientId: patientId,
            originNumberType: originNumberType,
            callerId: callerId,
            clinicId: clinicId,
            from: fromPhoneNumber
          });
          console.log('Making actual call with Twilio.Device');

          window._currentCall.on('ringing', () => {
            console.log('window.Twilio eventListener ringing');

            // Store the CallSid when the call is accepted
            try {
              if (window._currentCall && window._currentCall.parameters && window._currentCall.parameters.CallSid) {
                window._storedCallSid = window._currentCall.parameters.CallSid;
                console.log('Stored CallSid on accept:', window._storedCallSid);

                // Also store in localStorage to persist across page refreshes
                try {
                  localStorage.setItem('twilioCallSid', window._storedCallSid);
                } catch (e) {
                  console.error('Error storing CallSid in localStorage:', e);
                }

                // Also dispatch an event that Flutter can listen for
                try {
                  const callSidEvent = new CustomEvent('twilioCallSidReceived', {
                    detail: { callSid: window._storedCallSid }
                  });
                  window.dispatchEvent(callSidEvent);
                } catch (e) {
                  console.error('Error dispatching callSid event:', e);
                }
              } else {
                console.warn('Could not store CallSid: parameters or CallSid not available');
              }
            } catch (e) {
              console.error('Error storing CallSid on ringing:', e);
            }
          });          window._currentCall.on('accept', () => {
            console.log('window.Twilio eventListener accept');
          });          window._currentCall.on('disconnect', (event) => {
            console.log('=== TWILIO DISCONNECT EVENT ===');
            console.log('window.Twilio eventListener disconnect - event:', event);
            console.log('Disconnect event timestamp:', new Date().toISOString());
            console.log('Window context info:', {
              isPopup: window.opener ? true : false,
              openerExists: !!window.opener,
              openerClosed: window.opener ? window.opener.closed : 'N/A',
              windowName: window.name,
              windowLocation: window.location.href
            });
            
            // Clean up call reference
            window._currentCall = null;
            console.log('Cleaned up current call reference');
            
            // Dispatch event that call was disconnected (for same-window listeners)
            const disconnectEvent = new CustomEvent('twilioCallDisconnected');
            document.dispatchEvent(disconnectEvent);
            window.dispatchEvent(disconnectEvent);
            console.log('✅ twilioCallDisconnected event dispatched successfully on both document and window');
            
            // Try both approaches for cross-window communication
            let messageSent = false;
            
            // Approach 1: If this is a popup window, send message to parent
            if (window.opener && !window.opener.closed) {
              console.log('🔄 Sending disconnect message to parent window (via window.opener)...');
              try {
                const message = {
                  type: 'twilioCallDisconnected',
                  timestamp: new Date().toISOString(),
                  source: 'popup-opener',
                  debug: {
                    windowName: window.name,
                    location: window.location.href
                  }
                };
                window.opener.postMessage(message, '*');
                console.log('✅ Disconnect message sent to parent window via opener:', message);
                messageSent = true;
              } catch (e) {
                console.error('❌ Error sending message to parent window via opener:', e);
              }
            }
            
            // Approach 2: Also try to send to parent if we're in an iframe or popup context
            if (window.parent && window.parent !== window) {
              console.log('🔄 Sending disconnect message to parent window (via window.parent)...');
              try {
                const message = {
                  type: 'twilioCallDisconnected',
                  timestamp: new Date().toISOString(),
                  source: 'popup-parent',
                  debug: {
                    windowName: window.name,
                    location: window.location.href
                  }
                };
                window.parent.postMessage(message, '*');
                console.log('✅ Disconnect message sent to parent window via parent:', message);
                messageSent = true;
              } catch (e) {
                console.error('❌ Error sending message to parent window via parent:', e);
              }
            }
            
            // Approach 3: Broadcast to all windows if possible
            try {
              console.log('🔄 Broadcasting disconnect message...');
              const broadcastChannel = new BroadcastChannel('twilio-calls');
              const message = {
                type: 'twilioCallDisconnected',
                timestamp: new Date().toISOString(),
                source: 'broadcast',
                debug: {
                  windowName: window.name,
                  location: window.location.href
                }
              };
              broadcastChannel.postMessage(message);
              console.log('✅ Disconnect message broadcasted:', message);
              broadcastChannel.close();
              messageSent = true;
            } catch (e) {
              console.error('❌ Error broadcasting message:', e);
            }
            
            if (!messageSent) {
              console.log('ℹ️ No parent window available or parent window is closed - message not sent');
              console.log('Debug info:', {
                hasOpener: !!window.opener,
                openerClosed: window.opener ? window.opener.closed : 'N/A',
                hasParent: window.parent !== window,
                parentSame: window.parent === window,
                windowName: window.name,
                location: window.location.href
              });
            }
          });

          window._currentCall.on('cancel', (event) => {
            console.log('window.Twilio eventListener cancel - event:', event);
          });

          window._currentCall.on('reject', (event) => {
            console.log('window.Twilio eventListener reject - event:', event);
          });

          window._currentCall.on('error', (error) => {
            console.error('window.Twilio eventListener error:', error);
          });
          return true;
        } catch (e) {
          console.error('Error making call with Twilio.Device:', e);
          // Continue with stub implementation as fallback
        }
      }

      // Stub implementation
      console.log('Using stub makeCall implementation');
      alert('Simulating call to ' + toPhoneNumber);
      return true;
    } catch (e) {
      return handleTwilioError('makeCall', e);
    }
  };

  // Accept incoming call
  window.twilioHelper.acceptIncomingCall = function() {
    try {
      console.log('acceptIncomingCall called');

      if (window._incomingCall) {
        try {
          window._incomingCall.accept();
          console.log('Accepting actual incoming call with Twilio.Device');
          window._currentCall = window._incomingCall;

          // Store the CallSid for the incoming call
          if (window._incomingCall.parameters && window._incomingCall.parameters.CallSid) {
            window._storedCallSid = window._incomingCall.parameters.CallSid;
            console.log('Stored CallSid for incoming call:', window._storedCallSid);

            // Also store in localStorage
            try {
              localStorage.setItem('twilioCallSid', window._storedCallSid);
            } catch (e) {
              console.error('Error storing CallSid in localStorage:', e);
            }
          }

          return true;
        } catch (e) {
          console.error('Error accepting incoming call with Twilio.Device:', e);
          // Continue with stub implementation as fallback
        }
      } else {
        console.warn('No incoming call to accept');
      }

      // Stub implementation
      console.log('Using stub acceptIncomingCall implementation');
      return true;
    } catch (e) {
      return handleTwilioError('acceptIncomingCall', e);
    }  };

  // Reject incoming call
  window.twilioHelper.rejectIncomingCall = function() {
    try {
      console.log('rejectIncomingCall called');
      let callRejected = false;

      if (window._incomingCall) {
        try {
          window._incomingCall.reject();
          console.log('Rejecting actual incoming call with Twilio.Device');
          window._incomingCall = null;
          callRejected = true;
        } catch (e) {
          console.error('Error rejecting incoming call with Twilio.Device:', e);
          // Continue with stub implementation as fallback
        }
      } else {
        console.warn('No incoming call to reject');
      }

      // Always dispatch disconnect event for call summary (reject is treated as disconnect)
      console.log('Dispatching twilioCallDisconnected event for call summary after reject');
      const disconnectEvent = new CustomEvent('twilioCallDisconnected', {
        detail: {
          reason: callRejected ? 'user-reject' : 'stub-reject',
          timestamp: new Date().toISOString()
        }
      });
      document.dispatchEvent(disconnectEvent);
      window.dispatchEvent(disconnectEvent);
      console.log('✅ twilioCallDisconnected event dispatched from rejectIncomingCall');
      
      return true;
    } catch (e) {
      return handleTwilioError('rejectIncomingCall', e);
    }
  };
  // Define hangupCall with proper error handling
  window.twilioHelper.hangupCall = function() {
    try {
      console.log('hangupCall called');
      let callDisconnected = false;

      // Try to use real Twilio Device if available
      if (window._currentCall) {
        try {
          window._currentCall.disconnect();
          window._currentCall = null;
          console.log('Hanging up actual call with Twilio.Device');
          callDisconnected = true;
        } catch (e) {
          console.error('Error hanging up call with Twilio.Device:', e);
          // Continue with stub implementation as fallback
        }
      } else if (window._incomingCall) {
        // If we have an incoming call but it's not the current call, reject it
        try {
          window._incomingCall.reject();
          window._incomingCall = null;
          console.log('Rejecting incoming call with Twilio.Device');
          callDisconnected = true;
        } catch (e) {
          console.error('Error rejecting incoming call with Twilio.Device:', e);
        }
      }

      // Always dispatch disconnect event for call summary
      console.log('Dispatching twilioCallDisconnected event for call summary');
      const disconnectEvent = new CustomEvent('twilioCallDisconnected', {
        detail: {
          reason: callDisconnected ? 'user-hangup' : 'stub-hangup',
          timestamp: new Date().toISOString()
        }
      });
      document.dispatchEvent(disconnectEvent);
      window.dispatchEvent(disconnectEvent);
      console.log('✅ twilioCallDisconnected event dispatched from hangupCall');
      
      return true;
    } catch (e) {
      return handleTwilioError('hangupCall', e);
    }
  };
  // Define getCallStatus to return the current call status
  window.twilioHelper.getCallStatus = function() {
    try {
//      console.log('getCallStatus called');

      // Try to use real Twilio Device if available
      if (window._currentCall) {
        try {
          const status = window._currentCall.status();
          console.log('Current call status:', status);
          return status || 'unknown';
        } catch (e) {
          console.error('Error getting call status with Twilio.Device:', e);
        }
      } else if (window._incomingCall) {
        // If it's an incoming call that hasn't been answered yet
        return 'ringing';
      }

      // Return 'closed' if we don't have any active calls
      if (!window._currentCall && !window._incomingCall) {
        return 'closed';
      }

      // Return a simulated status if we're in stub mode or if error occurred
      if (window._twilioCallStatus) {
        return window._twilioCallStatus;
      } else {
        // First time called, set to connecting
        window._twilioCallStatus = 'connecting';

        // Set up a simulation of call state changes ONLY if we're in stub mode
        if (!window._twilioDevice) {
          setTimeout(() => {
            window._twilioCallStatus = 'ringing';
            console.log('Simulated call status changed to: ringing');

            setTimeout(() => {
              window._twilioCallStatus = 'accept';
              console.log('Simulated call status changed to: accept');
            }, 3000);
          }, 2000);
        }

        return 'connecting';
      }
    } catch (e) {
      return handleTwilioError('getCallStatus', e) || 'error';
    }
  };

  // Define toggleMute with proper error handling
  window.twilioHelper.toggleMute = function() {
    try {
      console.log('toggleMute called');

      // Try to use real Twilio Device if available
      if (window._currentCall) {
        try {
          var wasMuted = window._currentCall.isMuted();
          window._currentCall.mute(!wasMuted);
          console.log('Toggling mute with Twilio.Device, now muted:', !wasMuted);
          return !wasMuted;
        } catch (e) {
          console.error('Error toggling mute with Twilio.Device:', e);
        }
      }

      // Stub implementation
      return false;
    } catch (e) {
      return handleTwilioError('toggleMute', e);
    }
  };

  // Define sendDigits with proper error handling
  window.twilioHelper.sendDigits = function(digits) {
    try {
      console.log('sendDigits called with digits:', digits);

      // Try to use real Twilio Device if available
      if (window._currentCall) {
        try {
          window._currentCall.sendDigits(digits);
          console.log('Sending digits with Twilio.Device');
          return true;
        } catch (e) {
          console.error('Error sending digits with Twilio.Device:', e);
        }
      }

      // Stub implementation
      return true;
    } catch (e) {
      return handleTwilioError('sendDigits', e);
    }
  };

  // Define getAudioLevel with proper error handling
  window.twilioHelper.getAudioLevel = function() {
    try {
      // Stub implementation
      return Math.random() * 30; // Random level between 0-30
    } catch (e) {
      return handleTwilioError('getAudioLevel', e);
    }
  };

  // Define getCallSid to retrieve the CallSid from the current call
  window.twilioHelper.getCallSid = function() {
    try {
      console.log('getCallSid called');

      // First check for stored CallSid from accept event
      if (window._storedCallSid) {
        console.log('Returning stored CallSid:', window._storedCallSid);
        return window._storedCallSid;
      }

      // Try to retrieve from localStorage as backup
      try {
        const storedSid = localStorage.getItem('twilioCallSid');
        if (storedSid) {
          window._storedCallSid = storedSid;
          console.log('Retrieved CallSid from localStorage:', window._storedCallSid);
          return window._storedCallSid;
        }
      } catch (e) {
        console.error('Error accessing localStorage:', e);
      }

      // Try to retrieve CallSid from the current call if not already stored
      if (window._currentCall && window._currentCall.parameters) {
        try {
          const callSid = window._currentCall.parameters.CallSid;
          console.log('Retrieved CallSid from current call:', callSid);
          // Store for future calls
          if (callSid) {
            window._storedCallSid = callSid;
            try {
              localStorage.setItem('twilioCallSid', callSid);
            } catch (e) {
              console.error('Error storing CallSid in localStorage:', e);
            }
            return callSid;
          }
        } catch (e) {
          console.error('Error getting CallSid from Twilio.Device:', e);
        }
      }

      // Try incoming call if available
      if (window._incomingCall && window._incomingCall.parameters) {
        try {
          const callSid = window._incomingCall.parameters.CallSid;
          console.log('Retrieved CallSid from incoming call:', callSid);
          if (callSid) {
            window._storedCallSid = callSid;
            try {
              localStorage.setItem('twilioCallSid', callSid);
            } catch (e) {
              console.error('Error storing CallSid in localStorage:', e);
            }
            return callSid;
          }
        } catch (e) {
          console.error('Error getting CallSid from incoming call:', e);
        }
      }

      // Return empty string if we couldn't get the CallSid
      console.log('No CallSid available, returning empty string');
      return '';
    } catch (e) {
      return handleTwilioError('getCallSid', e) || '';
    }
  };  // Debug function to test event dispatch
  window.testDisconnectEvent = function() {
    console.log('🔧 Testing disconnect event dispatch...');
    const testEvent = new CustomEvent('twilioCallDisconnected');
    document.dispatchEvent(testEvent);
    window.dispatchEvent(testEvent);
    console.log('🔧 Test twilioCallDisconnected event dispatched on both document and window');
    
    // Also test cross-window messaging if this is a popup
    if (window.opener && !window.opener.closed) {
      console.log('🔧 Testing cross-window message to parent...');
      try {
        window.opener.postMessage({
          type: 'twilioCallDisconnected',
          timestamp: new Date().toISOString(),
          source: 'popup-test'
        }, '*');
        console.log('🔧 Test disconnect message sent to parent window successfully');
      } catch (e) {
        console.error('🔧 Error sending test message to parent window:', e);
      }
    } else {
      console.log('🔧 No parent window available for cross-window testing');
    }
    
    // Test BroadcastChannel
    try {
      console.log('🔧 Testing BroadcastChannel...');
      const broadcastChannel = new BroadcastChannel('twilio-calls');
      broadcastChannel.postMessage({
        type: 'twilioCallDisconnected',
        timestamp: new Date().toISOString(),
        source: 'broadcast-test'
      });
      console.log('🔧 Test message broadcasted');
      broadcastChannel.close();
    } catch (e) {
      console.error('🔧 Error with BroadcastChannel test:', e);
    }
  };
  
  // Advanced test function that simulates different window contexts
  window.testCrossWindowMessaging = function() {
    console.log('🔧 === COMPREHENSIVE CROSS-WINDOW MESSAGING TEST ===');
    
    const testMessage = {
      type: 'twilioCallDisconnected',
      timestamp: new Date().toISOString(),
      source: 'comprehensive-test',
      debug: {
        windowName: window.name,
        location: window.location.href,
        isPopup: !!window.opener,
        hasParent: window.parent !== window
      }
    };
    
    console.log('🔧 Test message:', testMessage);
    console.log('🔧 Window context:', {
      name: window.name,
      location: window.location.href,
      opener: !!window.opener,
      openerClosed: window.opener ? window.opener.closed : 'N/A',
      parent: window.parent !== window,
      parentSame: window.parent === window
    });
    
    // Test 1: Local event dispatch
    console.log('🔧 Test 1: Local event dispatch');
    const localEvent = new CustomEvent('twilioCallDisconnected', { detail: testMessage });
    document.dispatchEvent(localEvent);
    window.dispatchEvent(localEvent);
    console.log('✅ Local events dispatched');
    
    // Test 2: window.opener postMessage
    if (window.opener && !window.opener.closed) {
      console.log('🔧 Test 2: window.opener postMessage');
      try {
        window.opener.postMessage(testMessage, '*');
        console.log('✅ Message sent to opener');
      } catch (e) {
        console.error('❌ Error sending to opener:', e);
      }
    } else {
      console.log('⚠️ Test 2: No opener available');
    }
    
    // Test 3: window.parent postMessage
    if (window.parent && window.parent !== window) {
      console.log('🔧 Test 3: window.parent postMessage');
      try {
        window.parent.postMessage(testMessage, '*');
        console.log('✅ Message sent to parent');
      } catch (e) {
        console.error('❌ Error sending to parent:', e);
      }
    } else {
      console.log('⚠️ Test 3: No parent available');
    }
    
    // Test 4: BroadcastChannel
    try {
      console.log('🔧 Test 4: BroadcastChannel');
      const broadcastChannel = new BroadcastChannel('twilio-calls');
      broadcastChannel.postMessage(testMessage);
      console.log('✅ Message broadcasted');
      broadcastChannel.close();
    } catch (e) {
      console.error('❌ Error with BroadcastChannel:', e);
    }
    
    // Test 5: Self postMessage (should be caught by main window listener)
    console.log('🔧 Test 5: Self postMessage');
    try {
      window.postMessage(testMessage, '*');
      console.log('✅ Self message sent');
    } catch (e) {
      console.error('❌ Error with self message:', e);
    }
    
    console.log('🔧 === TEST COMPLETE ===');
  };

  // Debug function to check if Twilio is loaded correctly
  window.checkTwilioLoaded = function() {
    console.log("Twilio helper check:");

    // First check script loading status
    var scripts = Array.from(document.getElementsByTagName('script'));
    var twilioSDKLoaded = scripts.some(s => s.src && s.src.includes('twilio.js'));
    var twilioHelperLoaded = scripts.some(s => s.src && s.src.includes('twilio_helper.js'));

    // Check for twilio objects
    var helperExists = window.twilioHelper !== undefined;
    var setupExists = typeof window.twilioHelper?.setupTwilio === 'function';
    var sdkExists = typeof window.Twilio !== 'undefined';
    var deviceExists = sdkExists && typeof window.Twilio.Device === 'function';
    var readyFlagExists = typeof window.twilioHelperReady !== 'undefined';

    console.log("  - Script tags check:");
    console.log("  - Twilio SDK script:", twilioSDKLoaded ? "FOUND" : "NOT FOUND");
    console.log("  - Twilio Helper script:", twilioHelperLoaded ? "FOUND" : "NOT FOUND");
    console.log("  - Object check:");
    console.log("  - twilioHelper object exists:", helperExists);
    console.log("  - setupTwilio function exists:", setupExists);
    console.log("  - Twilio SDK exists:", sdkExists);
    console.log("  - Twilio.Device exists:", deviceExists);
    console.log("  - twilioHelperReady flag exists:", readyFlagExists);

    return {
      helperExists: helperExists,
      setupExists: setupExists,
      sdkExists: sdkExists,
      deviceExists: deviceExists,
      scriptsFound: {
        twilioSDK: twilioSDKLoaded,
        twilioHelper: twilioHelperLoaded
      },
      readyFlagExists: readyFlagExists,
      readyFlagValue: window.twilioHelperReady
    };
  };

  // Set the twilioHelperReady flag to true
  window.twilioHelperReady = true;

  // Make sure the ready flag is properly set and protected
  Object.defineProperty(window, 'twilioHelperReady', {
    value: true,
    writable: true,
    configurable: true
  });

  console.log('Twilio helper loaded and ready with all required functions');

  // Verify all required functions are available
  const requiredFunctions = ['setupTwilio', 'makeCall', 'hangupCall', 'toggleMute', 'sendDigits', 'getAudioLevel', 'getCallSid', 'acceptIncomingCall', 'rejectIncomingCall'];
  const missingFunctions = requiredFunctions.filter(f => typeof window.twilioHelper[f] !== 'function');

  if (missingFunctions.length > 0) {
    console.error('Missing Twilio helper functions:', missingFunctions.join(', '));
    // Try to fix any missing functions
    missingFunctions.forEach(f => {
      window.twilioHelper[f] = function() {
        console.log('AUTO-CREATED ' + f + ' called');
        return f === 'getAudioLevel' ? 0 : (f === 'getCallSid' ? '' : true);
      };
    });
  }

  // Define transferCall with proper error handling
  window.twilioHelper.transferCall = function(emailAddress, callSid) {
    try {
      console.log('transferCall called with email:', emailAddress, 'callSid:', callSid);

      // Create and dispatch a custom event for the transfer
      const transferEvent = new CustomEvent('twilioCallTransfer', {
        detail: {
          emailAddress: emailAddress,
          callSid: callSid || window.twilioHelper.getCallSid(),
          timestamp: new Date().toISOString()
        }
      });

      // Dispatch on both document and window to ensure it's captured
      document.dispatchEvent(transferEvent);
      window.dispatchEvent(transferEvent);
      console.log('✅ twilioCallTransfer event dispatched with:', {
        emailAddress: emailAddress,
        callSid: callSid || window.twilioHelper.getCallSid()
      });

      // Try to use real Twilio Device if available
      if (window._currentCall) {
        try {
          // Instead of using sendDigits, we'll use the event approach
          // This allows the transfer to be handled by external systems
          console.log('Current call found, attaching transfer data');

          // Store transfer info on the call object for reference
          window._currentCall.transferInfo = {
            emailAddress: emailAddress,
            callSid: callSid || window._storedCallSid || window.twilioHelper.getCallSid(),
            initiated: new Date().toISOString()
          };

          // Optional: Send DTMF tones that might be used for transfer in some setups
          if (typeof window.twilioHelper.sendDigits === 'function') {
            window.twilioHelper.sendDigits("*8"); // Example transfer sequence
            console.log("Transfer sequence sent via twilioHelper.sendDigits");
          }

          return true;
        } catch (e) {
          console.error('Error initiating transfer with Twilio.Device:', e);
          // Continue with event-based implementation as fallback
        }
      }

      // Broadcast transfer request via BroadcastChannel if available
      try {
        const broadcastChannel = new BroadcastChannel('twilio-calls');
        broadcastChannel.postMessage({
          type: 'twilioCallTransfer',
          emailAddress: emailAddress,
          callSid: callSid || window.twilioHelper.getCallSid(),
          timestamp: new Date().toISOString()
        });
        console.log('Transfer request broadcasted via BroadcastChannel');
        broadcastChannel.close();
      } catch (e) {
        console.error('Error broadcasting transfer via BroadcastChannel:', e);
      }

      return true;
    } catch (e) {
      console.error('Error in transferCall:', e);
      // Return true to prevent UI from showing an error
      return true;
    }
  };
})();

