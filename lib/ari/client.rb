require "ari/errors"
require "ari/http_services"

module ARI
  # @!attribute [r] host
  #   @return [String] Host name
  # @!attribute [r] port
  #   @return [Integer] Port number
  # @!attribute [r] prefix
  #   @return [String] Prefix allows you to specify a prefix for all requests to the server.
  # @!attribute [r] username
  #   @return [String] username for basic auth
  # @!attribute [r] password
  #   @return [String] password for basic auth
  class Client

    # @param [Hash] options
    # @option options [String] :host ("localhost") Host name
    # @option options [Integer] :port (8088) Port number
    # @option options [String] :prefix Prefix allows you to specify a prefix for all requests to the server.
    # @option options [String] :username username for basic auth
    # @option options [String] :password password for basic auth
    def initialize(options = {})
      @host     = options[:host] || "localhost"
      @port     = options[:port] || 8088
      @prefix   = options[:prefix] if options[:prefix]
      @username = options[:username] if options[:username]
      @password = options[:password] if options[:password]
    end
    attr_reader :host, :port, :prefix, :username, :password

    %w(get post put delete).each do |verb|
      define_method(verb) do |path, params = {}|
        api_call(path, params, verb)
      end
    end

    # Asterisk REST API

    # GET
    # /asterisk/info
    # AsteriskInfo
    # Gets Asterisk system information.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Asterisk+REST+API#Asterisk12AsteriskRESTAPI-getInfo
    #
    # @param [String] only Filter information returned. Allows comma separated values.
    def asterisk_get_info
      get "asterisk/info"
    end

    # GET
    # /asterisk/variable
    # Variable
    # Get the value of a global variable.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Asterisk+REST+API#Asterisk12AsteriskRESTAPI-getGlobalVar
    #
    # @param [Hash] params
    # @option params [String] variable *required The variable to get
    #
    # Error Responses
    #
    # return 400 - Missing variable parameter.
    def asterisk_get_global_var(params = {})
      get "asterisk/variable", params
    end

    # POST
    # /asterisk/variable
    # void
    # Set the value of a global variable.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Asterisk+REST+API#Asterisk12AsteriskRESTAPI-setGlobalVar
    #
    # @param [Hash] params
    # @option params [String] :variable *required The variable to set
    # @option params [String] :value The value to set the variable to
    #
    # Error Responses
    # 400 - Missing variable parameter.
    def asterisk_set_global_var(params = {})
      post "asterisk/variable", params
    end


    # Bridges REST API
    #

    # GET
    # /bridges
    # List[Bridge]
    # List all active bridges in Asterisk.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-list
    def bridges_list
      get "bridges"
    end

    # POST
    # /bridges
    # Bridge
    # Create a new bridge.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-create
    #
    # @param [Hash] params
    # @option params [String] :type Comma separated list of bridge type attributes (mixing, holding, dtmf_events, proxy_media).
    # @option params [String] :bridgeId Unique ID to give to the bridge being created.
    # @option params [String] :name Name to give to the bridge being created.
    def bridges_create(params = {})
      post "bridges", params
    end

    # POST
    # /bridges/:bridgeId
    # Bridge
    # Create a new bridge or updates an existing one.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-create_or_update_with_id
    #
    # @param [String] bridge_id Unique ID to give to the bridge being created.
    # @param [Hash] params
    # @option params [String] :type Comma separated list of bridge type attributes (mixing, holding, dtmf_events, proxy_media) to set.
    # @option params [String] :name Set the name of the bridge.
    def bridges_create_or_update_with_id(bridge_id, params = {})
      post "bridges/#{bridge_id}", params
    end

    # GET
    # /bridges/:bridgeId
    # Bridge
    # Get bridge details.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-get
    #
    # @param [String] bridge_id Bridge's id
    #
    # Error Responses
    #
    # 404 - Bridge not found
    def bridges_get(bridge_id)
      get "bridges/#{bridge_id}"
    end

    # DELETE
    # /bridges/:bridgeId
    # void
    # Shut down a bridge.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-destroy
    #
    # @param [String] bridge_id Bridge's id
    #
    # Error Responses
    #
    # 404 - Bridge not found
    def bridges_destroy(bridge_id)
      delete "bridges/#{bridge_id}"
    end

    # POST
    # /bridges/:bridgeId/addChannel
    # void
    # Add a channel to a bridge.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-addChannel
    #
    # @param [String] bridge_id Bridge's id
    # @param [Hash] params
    # @option params [String] :channel *required Ids of channels to add to bridge
    # Allows comma separated values.
    # @option params [String] :role Channel's role in the bridge
    #
    # Error Responses
    #
    # 400 - Channel not found
    # 404 - Bridge not found
    # 409 - Bridge not in Stasis application; Channel currently recording
    # 422 - Channel not in Stasis application
    def bridges_add_channel(bridge_id, params = {})
      post "bridges/#{bridge_id}/addChannel", params
    end

    # POST
    # /bridges/:bridgeId/removeChannel
    # void
    # Remove a channel from a bridge.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-removeChannel
    #
    # @param [String] bridge_id Bridge's id
    # @param [Hash] params
    # @option params [String] :channel *required Ids of channels to remove from bridge. Allows comma separated values.
    #
    # Error Responses
    #
    # 400 - Channel not found
    # 404 - Bridge not found
    # 409 - Bridge not in Stasis application
    # 422 - Channel not in this bridge
    def bridges_remove_channel(bridge_id, params = {})
      post "bridges/#{bridge_id}/removeChannel", params
    end

    # POST
    # /bridges/:bridgeId/moh
    # void
    # Play music on hold to a bridge or change the MOH class that is playing.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-startMoh
    #
    # @param [String] bridge_id Bridge's id
    # @param [Hash] params
    # @option params [String] :mohClass Channel's id
    #
    # Error Responses
    #
    # 404 - Bridge not found
    # 409 - Bridge not in Stasis application
    def bridges_start_moh(bridge_id, params = {})
      post "bridges/#{bridge_id}/moh", params
    end

    # DELETE
    # /bridges/:bridgeId/moh
    # void
    # Stop playing music on hold to a bridge.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-stopMoh
    #
    # @param [String] bridge_id Bridge's id
    #
    # Error Responses
    # 404 - Bridge not found
    # 409 - Bridge not in Stasis application
    def bridges_stop_moh(bridge_id)
      delete "bridges/#{bridge_id}/moh"
    end

    # POST
    # /bridges/:bridgeId/play
    # Playback
    # Start playback of media on a bridge.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-play
    #
    # @param [String] bridge_id Bridge's id
    # @param [Hash] params
    # @option params [String] :media *required Media's URI to play.
    # @option params [String] :lang For sounds, selects language for sound.
    # @option params [Integer] :offsetms Number of media to skip before playing.
    # @option params [Integer] :skipms (3000) Number of milliseconds to skip for forward/reverse operations.
    # @option params [String] :playbackId Playback Id.
    #
    # Error Responses
    #
    # 404 - Bridge not found
    # 409 - Bridge not in a Stasis application
    def bridges_play(bridge_id, params = {})
      post "bridges/#{bridge_id}/play", params
    end

    # POST
    # /bridges/:bridgeId/play/:playbackId
    # Playback
    # Start playback of media on a bridge.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-playWithId
    #
    # @param [String] bridge_id Bridge's id
    # @param [String] playback_id Playback ID.
    # @param [Hash] params
    # @option params [String] :media *required Media's URI to play.
    # @option params [String] :lang For sounds, selects language for sound.
    # @option params [Integer] :offsetms Number of media to skip before playing.
    # @option params [Integer] :skipms (3000) Number of milliseconds to skip for forward/reverse operations.
    #
    # Error Responses
    #
    # 404 - Bridge not found
    # 409 - Bridge not in a Stasis application
    def bridges_play_with_id(bridge_id, playback_id, params = {})
      post "bridges/#{bridge_id}/play/#{playback_id}", params
    end

    # POST
    # /bridges/:bridgeId/record
    # LiveRecording
    # Start a recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Bridges+REST+API#Asterisk12BridgesRESTAPI-record
    #
    # @param [String] bridge_id Bridge's id
    # @param [Hash] params
    # @option params [String] :name *required Recording's filename
    # @option params [String] :format *required Format to encode audio in
    # @option params [Integer] :maxDurationSeconds Maximum duration of the recording, in seconds. 0 for no limit.
    # @option params [Integer] :maxSilenceSeconds Maximum duration of silence, in seconds. 0 for no limit.
    # @option params [String] :ifExists ("fail") Action to take if a recording with the same name already exists.
    # @option params [Boolean] :beep Play beep when recording begins
    # @option params [String] :terminateOn ("none") DTMF input to terminate recording.
    #
    # Error Responses
    #
    # 400 - Invalid parameters
    # 404 - Bridge not found
    # 409 - Bridge is not in a Stasis application; A recording with the same name already exists on the system and can not be overwritten because it is in progress or ifExists=fail
    # 422 - The format specified is unknown on this system
    def bridges_record(bridge_id, params = {})
      post "bridges/#{bridge_id}/record", params
    end

    # Channels REST API
    # GET
    # /channels
    # List[Channel]
    # List all active channels in Asterisk.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-list
    #
    def channels_list
      get "channels"
    end

    # POST
    # /channels
    # Channel
    # Create a new channel (originate).
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-originate
    #
    # @param [Hash] params
    # @option params [String] :endpoint *required Endpoint to call.
    # @option params [String] :extension The extension to dial after the endpoint answers
    # @option params [String] :context The context to dial after the endpoint answers. If omitted, uses 'default'
    # @option params [Long] :priority The priority to dial after the endpoint answers. If omitted, uses 1
    # @option params [String] :app The application that is subscribed to the originated channel, and passed to the Stasis application.
    # @option params [String] :appArgs The application arguments to pass to the Stasis application.
    # @option params [String] :callerId CallerID to use when dialing the endpoint or extension.
    # @option params [Integer] :timeout (30) Timeout (in seconds) before giving up dialing, or -1 for no timeout.
    # @option params [String] :channelId The unique id to assign the channel on creation.
    # @option params [String] :otherChannelId The unique id to assign the second channel when using local channels.
    #
    # Body parameter
    #
    # variables: containers - The "variables" key in the body object holds variable key/value pairs to set on the channel on creation. Other keys in the body object are interpreted as query parameters. Ex. { "endpoint": "SIP/Alice", "variables": { "CALLERID(name)": "Alice" } }
    #
    # Error Responses
    #
    # 400 - Invalid parameters for originating a channel.
    def channels_originate(params = {})
      post "channels", params
    end

    # GET
    # /channels/:channelId
    # Channel
    # Channel details.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-get
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    def channels_get(channel_id)
      get "channels/#{channel_id}"
    end

    # POST
    # /channels/:channelId
    # Channel
    # Create a new channel (originate with id).
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-originateWithId
    #
    # @param [String] channel_id The unique id to assign the channel on creation.
    # @param [Hash] params
    # @option params [String] :endpoint *required Endpoint to call.
    # @option params [String] :extension The extension to dial after the endpoint answers
    # @option params [String] :context The context to dial after the endpoint answers. If omitted, uses 'default'
    # @option params [Long] priority The priority to dial after the endpoint answers. If omitted, uses 1
    # @option params [String] :app The application that is subscribed to the originated channel, and passed to the Stasis application.
    # @option params [String] :appArgs The application arguments to pass to the Stasis application.
    # @option params [String] :callerId CallerID to use when dialing the endpoint or extension.
    # @option params [Integer] :timeout (30) Timeout (in seconds) before giving up dialing, or -1 for no timeout.
    # @option params [String] :otherChannelId The unique id to assign the second channel when using local channels.
    #
    # Body parameter
    #
    # variables: containers - The "variables" key in the body object holds variable key/value pairs to set on the channel on creation. Other keys in the body object are interpreted as query parameters. Ex. { "endpoint": "SIP/Alice", "variables": { "CALLERID(name)": "Alice" } }
    #
    # Error Responses
    #
    # 400 - Invalid parameters for originating a channel.
    def channels_originate_with_id(channel_id, params = {})
      post "channels/#{channel_id}", params
    end

    # DELETE
    # /channels/:channelId
    # void
    # Delete (i.e. hangup) a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-hangup
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :reason Reason for hanging up the channel
    #
    # Error Responses
    #
    # 400 - Invalid reason for hangup provided
    # 404 - Channel not found
    def channels_hangup(channel_id, params = {})
      delete "channels/#{channel_id}", params
    end

    # POST
    # /channels/:channelId/continue
    # void
    # Exit application; continue execution in the dialplan.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-continueInDialplan
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :context The context to continue to.
    # @option params [String] :extension The extension to continue to.
    # @option params [Integer] :priority The priority to continue to.
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_continue_in_dialplan(channel_id, params = {})
      post "channels/#{channel_id}/continue", params
    end

    # POST
    # /channels/:channelId/answer
    # void
    # Answer a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-answer
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_answer(channel_id)
      post "channels/#{channel_id}/answer"
    end

    # POST
    # /channels/:channelId/ring
    # void
    # Indicate ringing to a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-ring
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_ring(channel_id)
      post "channels/#{channel_id}/ring"
    end

    # DELETE
    # /channels/:channelId/ring
    # void
    # Stop ringing indication on a channel if locally generated.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-ringStop
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_ring_stop(channel_id)
      delete "channels/#{channel_id}/ring"
    end

    # POST
    # /channels/:channelId/dtmf
    # void
    # Send provided DTMF to a given channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-sendDTMF
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :dtmf DTMF To send.
    # @option params [Integer] :before Amount of time to wait before DTMF digits (specified in milliseconds) start.
    # @option params [Integer] :between (100) Amount of time in between DTMF digits (specified in milliseconds).
    # @option params [Integer] :duration (100) Length of each DTMF digit (specified in milliseconds).
    # @option params [Integer] :after Amount of time to wait after DTMF digits (specified in milliseconds) end.
    #
    # Error Responses
    #
    # 400 - DTMF is required
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_send_dtmf(channel_id, params = {})
      post "channels/#{channel_id}/dtmf", params
    end

    # POST
    # /channels/:channelId/mute
    # void
    # Mute a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-mute
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :direction ("both") Direction in which to mute audio
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_mute(channel_id, params = {})
      post "channels/#{channel_id}/mute", params
    end

    # DELETE
    # /channels/:channelId/mute
    # void
    # Unmute a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-unmute
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :direction ("both") Direction in which to unmute audio
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_unmute(channel_id, params = {})
      delete "channels/#{channel_id}/mute", params
    end

    # POST
    # /channels/:channelId/hold
    # void
    # Hold a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-hold
    #
    # @param [String] channel_id  Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_hold(channel_id)
      post "channels/#{channel_id}/hold"
    end

    # DELETE
    # /channels/:channelId/hold
    # void
    # Remove a channel from hold.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-unhold
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_unhold(channel_id)
      delete "channels/#{channel_id}/hold"
    end

    # POST
    # /channels/:channelId/moh
    # void
    # Play music on hold to a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-startMoh
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :mohClass Music on hold class to use
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_start_moh(channel_id, params = {})
      post "channels/#{channel_id}/moh", params
    end

    # DELETE
    # /channels/:channelId/moh
    # void
    # Stop playing music on hold to a channel.
    # POST
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-stopMoh
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_stop_moh(channel_id)
      delete "channels/#{channel_id}/moh"
    end

    # /channels/:channelId/silence
    # void
    # Play silence to a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-startSilence
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_start_silence(channel_id)
      post "channels/#{channel_id}/silence"
    end

    # DELETE
    # /channels/:channelId/silence
    # void
    # Stop playing silence to a channel.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-stopSilence
    #
    # @param [String] channel_id Channel's id
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_stop_silence(channel_id)
      delete "channels/#{channel_id}/silence"
    end

    # POST
    # /channels/:channelId/play
    # Playback
    # Start playback of media.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-play
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :media *required Media's URI to play.
    # @option params [String] :lang For sounds, selects language for sound.
    # @option params [Integer] :offsetms Number of media to skip before playing.
    # @option params [Integer] :skipms (3000) Number of milliseconds to skip for forward/reverse operations.
    # @option params [String] :playbackId Playback ID.
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_play(channel_id, params = {})
      post "channels/#{channel_id}/play", params
    end

    # POST
    # /channels/:channelId/play/:playbackId
    # Playback
    # Start playback of media and specify the playbackId.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-playWithId
    #
    # @param [String] channel_id channel_id
    # @param [String] playback_id playback_id
    # @param [Hash] params
    # @option params [String] :media *required Media's URI to play.
    # @option params [String] :lang For sounds, selects language for sound.
    # @option params [Integer] :offsetms Number of media to skip before playing.
    # @option params [Integer] :skipms (3000) Number of milliseconds to skip for forward/reverse operations.
    #
    # Error Responses
    #
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_play_with_id(channel_id, playback_id, params = {})
      post "channels/#{channel_id}/play/#{playback_id}", params
    end

    # POST
    # /channels/:channelId/record
    # LiveRecording
    # Start a recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-record
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :name *required Recording's filename
    # @option params [String] :format *required Format to encode audio in
    # @option params [Integer] :maxDurationSeconds Maximum duration of the recording, in seconds. 0 for no limit
    # @option params [Integer] :maxSilenceSeconds Maximum duration of silence, in seconds. 0 for no limit
    # @option params [String] :ifExists ("fail") - Action to take if a recording with the same name already exists.
    # @option params [Boolen] :beep Play beep when recording begins
    # @option params [String] :terminateOn ("none") DTMF input to terminate recording
    #
    # Error Responses
    #
    # 400 - Invalid parameters
    # 404 - Channel not found
    # 409 - Channel is not in a Stasis application; the channel is currently bridged with other hcannels; A recording with the same name already exists on the system and can not be overwritten because it is in progress or ifExists=fail
    # 422 - The format specified is unknown on this system
    def channels_record(channel_id, params = {})
      post "channels/#{channel_id}/record", params
    end

    # GET
    # /channels/:channelId/variable
    # Variable
    # Get the value of a channel variable or function.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-getChannelVar
    #
    # @param [String] channel_id channel_id
    # @param [Hash] params
    # @option params [String] :variable *required The channel variable or function to get
    #
    # Error Responses
    #
    # 400 - Missing variable parameter.
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_get_channel_var(channel_id, params = {})
      get "channels/#{channel_id}/variable", params
    end

    # POST
    # /channels/:channelId/variable
    # void
    # Set the value of a channel variable or function.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-setChannelVar
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :variable *required The channel variable or function to set
    # @option params [String] :value The value to set the variable to
    #
    # Error Responses
    #
    # 400 - Missing variable parameter.
    # 404 - Channel not found
    # 409 - Channel not in a Stasis application
    def channels_set_channel_var(channel_id, params = {})
      post "channels/#{channel_id}/variable", params
    end

    # POST
    # /channels/:channelId/snoop
    # Channel
    # Start snooping.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-snoopChannel
    #
    # @param [String] channel_id Channel's id
    # @param [Hash] params
    # @option params [String] :spy ("none") Direction of audio to spy on
    # @option params [String] :whisper ("none") Direction of audio to whisper into
    # @option params [String] :app *required Application the snooping channel is placed into
    # @option params [String] :appArgs The application arguments to pass to the Stasis application
    # @option params [String] :snoopId Unique ID to assign to snooping channel
    #
    # Error Responses
    #
    # 400 - Invalid parameters
    # 404 - Channel not found
    def channels_snoop_channel(channel_id, params = {})
      post "channels/#{channel_id}/snoop", params
    end

    # POST
    # /channels/:channelId/snoop/:snoopId
    # Channel
    # Start snooping.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Channels+REST+API#Asterisk12ChannelsRESTAPI-snoopChannelWithId
    #
    # @param [String] channel_id Channel's id
    # @param [String] snoop_id Unique ID to assign to snooping channel
    # @param [Hash] params
    # @option param [String] :spy ("none") Direction of audio to spy on
    # @option param [String] :whisper ("none") Direction of audio to whisper into
    # @option param [String] :app *required Application the snooping channel is placed into
    # @option param [String] :appArgs The application arguments to pass to the Stasis application
    #
    # Error Responses
    #
    # 400 - Invalid parameters
    # 404 - Channel not found
    def channels_snoop_channel_with_id(channel_id, snoop_id, params = {})
      post "channels/#{channel_id}/snoop/#{snoop_id}", params
    end

    # Endpoints REST API

    # GET
    # /endpoints
    # List[Endpoint]
    # List all endpoints.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Endpoints+REST+API#Asterisk12EndpointsRESTAPI-list
    def endpoints_list
      get "endpoints"
    end

    # PUT
    # /endpoints/sendMessage
    # void
    # Send a message to some technology URI or endpoint.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Endpoints+REST+API#Asterisk12EndpointsRESTAPI-sendMessage
    #
    # @param [Hash] params
    # @option param [String] to *required The endpoint resource or technology specific URI to send the message to. Valid resources are sip, pjsip, and xmpp.
    # @option param [String] from *required The endpoint resource or technology specific identity to send this message from. Valid resources are sip, pjsip, and xmpp.
    # @option param [String] body The body of the message
    #
    # Body parameter
    #
    # variables: containers -
    #
    # Error Responses
    #
    # 404 - Endpoint not found
    def endpoints_send_message(params = {})
      put "endpoints/sendMessage", params
    end

    # GET
    # /endpoints/:tech
    # List[Endpoint]
    # List available endoints for a given endpoint technology.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Endpoints+REST+API#Asterisk12EndpointsRESTAPI-listByTech
    #
    # @param [String] tech Technology of the endpoints (sip,iax2,...)
    #
    # Error Responses
    #
    # 404 - Endpoints not found
    def endpoints_list_by_tech(tech)
      get "endpoints/#{tech}"
    end

    # GET
    # /endpoints/:tech/:resource
    # Endpoint
    # Details for an endpoint.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Endpoints+REST+API#Asterisk12EndpointsRESTAPI-get
    #
    # @param [String] tech Technology of the endpoint
    # @param [String] resource ID of the endpoint
    #
    # Error Responses
    #
    # 400 - Invalid parameters for sending a message.
    # 404 - Endpoints not found
    def endpoints_get(tech, resource)
      get "endpoints/#{tech}/#{resource}"
    end

    # PUT
    # /endpoints/:tech/:resource/sendMessage
    # void
    # Send a message to some endpoint in a technology.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Endpoints+REST+API#Asterisk12EndpointsRESTAPI-sendMessageToEndpoint
    #
    # @param [String] tech Technology of the endpoint
    # @param [String] resource ID of the endpoint
    # @param [Hash] params
    # @option params [String] :from *required The endpoint resource or technology specific identity to send this message from. Valid resources are sip, pjsip, and xmpp.
    # @option params [String] :body The body of the message
    #
    # Body parameter
    #
    # variables: containers -
    #
    # Error Responses
    #
    # 400 - Invalid parameters for sending a message.
    # 404 - Endpoint not found
    def endpoints_send_message_to_endpoint(tech, resource, params = {})
      put "endpoints/#{tech}/#{resource}/sendMessage", params
    end

    # TODO
    # # Events REST API

    # # GET
    # # /events
    # # Message
    # # WebSocket connection for events.
    # #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Events+REST+API#Asterisk12EventsRESTAPI-eventWebsocket
    # def events_event_websocket
    #   get "events"
    # end

    # # POST
    # # /events/user/{eventName}
    # # void
    # # Generate a user event.
    # #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Events+REST+API#Asterisk12EventsRESTAPI-userEvent
    # #
    # # @param [String] event_name event_name
    # def events_user_event(event_name)
    #   post "events/user/#{event_name}"
    # end

    # Recordings REST API

    # GET
    # /recordings/stored
    # List[StoredRecording]
    # List recordings that are complete.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-listStored
    def recordings_list_stored
      get "recordings/stored"
    end

    # GET
    #
    # /recordings/stored/:recordingName
    #
    # StoredRecording
    # Get a stored recording's details.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-getStored
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    def recordings_get_stored(recording_name)
      get "recordings/stored/#{recording_name}"
    end

    # DELETE
    # /recordings/stored/:recordingName
    # void
    # Delete a stored recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-deleteStored
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    def recordings_delete_stored(recording_name)
      delete "recordings/stored/#{recording_name}"
    end

    # POST
    # /recordings/stored/:recordingName/copy
    # StoredRecording
    # Copy a stored recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-copyStored
    #
    # @param [String] recording_name The name of the recording to copy
    # @param [Hash] params
    # @option params [String] :destinationRecordingName *required The destination name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    # 409 - A recording with the same name already exists on the system
    def recordings_copy_stored(recording_name, params = {})
      post "recordings/stored/#{recording_name}/copy", params
    end

    # GET
    # /recordings/live/:recordingName
    # LiveRecording
    # List live recordings.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-getLive
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    def recordings_get_live(recording_name)
      get "recordings/live/#{recording_name}"
    end

    # DELETE
    # /recordings/live/:recordingName
    # void
    # Stop a live recording and discard it.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-cancel
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    def recordings_cancel(recording_name)
      delete "recordings/live/#{recording_name}"
    end

    # POST
    # /recordings/live/:recordingName/stop
    # void
    # Stop a live recording and store it.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-stop
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    def recordings_stop(recording_name)
      post "recordings/live/#{recording_name}/stop"
    end

    # POST
    # /recordings/live/:recordingName/pause
    # void
    # Pause a live recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-pause
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    # 409 - Recording not in session
    def recordings_pause(recording_name)
      post "recordings/live/#{recording_name}/pause"
    end

    # DELETE
    # /recordings/live/:recordingName/pause
    # void
    # Unpause a live recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-unpause
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    # 409 - Recording not in session
    def recordings_unpause(recording_name)
      delete "recordings/live/#{recording_name}/pause"
    end

    # POST
    # /recordings/live/:recordingName/mute
    # void
    # Mute a live recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-mute
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    # 409 - Recording not in session
    def recordings_mute(recording_name)
      post "recordings/live/#{recording_name}/mute"
    end

    # DELETE
    # /recordings/live/:recordingName/mute
    # void
    # Unmute a live recording.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Recordings+REST+API#Asterisk12RecordingsRESTAPI-unmute
    #
    # @param [String] recording_name The name of the recording
    #
    # Error Responses
    #
    # 404 - Recording not found
    # 409 - Recording not in session
    def recordings_unmute(recording_name)
      delete "recordings/live/#{recording_name}/mute"
    end

    # Sounds REST API

    # GET
    # /sounds
    # List[Sound]
    # List all sounds.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Sounds+REST+API#Asterisk12SoundsRESTAPI-list
    #
    # @param [Hash] params
    # @option param [String] lang Lookup sound for a specific language.
    # @option param [String] format Lookup sound in a specific format.
    def sounds_list(params = {})
      get "sounds", params
    end

    # GET
    # /sounds/:soundId
    # Sound
    # Get a sound's details.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Sounds+REST+API#Asterisk12SoundsRESTAPI-get
    #
    # @param [String] sound_id Sound's id
    def sounds_get(sound_id)
      get "sounds/#{sound_id}"
    end

    # Applications REST API

    # GET
    # /applications
    # List[Application]
    # List all applications.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Applications+REST+API#Asterisk12ApplicationsRESTAPI-list
    def applications_list
      get "applications"
    end

    # GET
    # /applications/:applicationName
    # Application
    # Get details of an application.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Applications+REST+API#Asterisk12ApplicationsRESTAPI-get
    #
    # @param [String] application_name Application's name
    #
    # Error Responses
    #
    # 404 - Application does not exist.
    def applications_get(application_name)
      get "applications/#{application_name}"
    end

    # POST
    # /applications/:applicationName/subscription
    # Application
    # Subscribe an application to a event source.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Applications+REST+API#Asterisk12ApplicationsRESTAPI-subscribe
    #
    # @param [String] application_name Application's name
    # @param [Hash] params
    # @option params [String] :eventSource *required URI for event source (channel:{channelId}, bridge:{bridgeId}, endpoint:{tech}[/{resource}], deviceState:{deviceName}. Allows comma separated values.
    #
    # Error Responses
    #
    # 400 - Missing parameter.
    # 404 - Application does not exist.
    # 422 - Event source does not exist.
    def applications_subscribe(application_name, params = {})
      post "applications/#{application_name}/subscription", params
    end

    # DELETE
    # /applications/:applicationName/subscription
    # Application
    # Unsubscribe an application from an event source.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Applications+REST+API#Asterisk12ApplicationsRESTAPI-unsubscribe
    #
    # @param [String] application_name Application's name
    # @param [Hash] params
    # @option params [String] :eventSource *required URI for event source (channel:{channelId}, bridge:{bridgeId}, endpoint:{tech}[/{resource}], deviceState:{deviceName}. Allows comma separated values.
    #
    # Error Responses
    #
    # 400 - Missing parameter.
    # 404 - Application does not exist.
    # 409 - Application not subscribed to event source.
    # 422 - Event source does not exist.
    def applications_unsubscribe(application_name, params = {})
      delete "applications/#{application_name}/subscription", params
    end

    # Playbacks REST API

    # GET
    # /playbacks/:playbackId
    # Playback
    # Get a playback's details.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Playbacks+REST+API#Asterisk12PlaybacksRESTAPI-get
    #
    # @param [String] playback_id Playback's id
    #
    # Error Responses
    #
    # 404 - The playback cannot be found
    def playbacks_get(playback_id)
      get "playbacks/#{playback_id}"
    end

    # DELETE
    # /playbacks/:playbackId
    # void
    # Stop a playback.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Playbacks+REST+API#Asterisk12PlaybacksRESTAPI-stop
    #
    # @param [String] playback_id Playback's id
    #
    # Error Responses
    #
    # 404 - The playback cannot be found
    def playbacks_stop(playback_id)
      delete "playbacks/#{playback_id}"
    end

    # POST
    # /playbacks/:playbackId/control
    # void
    # Control a playback.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Playbacks+REST+API#Asterisk12PlaybacksRESTAPI-control
    #
    # @param [String] playback_id Playback's id
    # @param [Hash] params
    # @option params [String] :operation *required Operation to perform on the playback.
    #
    # Error Responses
    #
    # 400 - The provided operation parameter was invalid
    # 404 - The playback cannot be found
    # 409 - The operation cannot be performed in the playback's current state
    def playbacks_control(playback_id, params = {})
      post "playbacks/#{playback_id}/control", params
    end

    # Devicestates REST API

    # GET
    # /deviceStates
    # List[DeviceState]
    # List all ARI controlled device states.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Devicestates+REST+API#Asterisk12DevicestatesRESTAPI-list
    def device_states_list
      get "deviceStates"
    end

    # GET
    # /deviceStates/:deviceName
    # DeviceState
    # Retrieve the current state of a device.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Devicestates+REST+API#Asterisk12DevicestatesRESTAPI-get
    #
    # @param [String] device_name Name of the device
    def device_states_get(device_name)
      get "deviceStates/#{device_name}"
    end

    # PUT
    # /deviceStates/:deviceName
    # void
    # Change the state of a device controlled by ARI. (Note - implicitly creates the device state).
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Devicestates+REST+API#Asterisk12DevicestatesRESTAPI-update
    #
    # @param [String] device_name Name of the device
    # @param [Hash] params
    # @option params [String] :deviceState *required Device state value
    #
    # Error Responses
    #
    # 404 - Device name is missing
    # 409 - Uncontrolled device specified
    def device_states_update(device_name, params = {})
      put "deviceStates/#{device_name}", params
    end

    # DELETE
    # /deviceStates/:deviceName
    # void
    # Destroy a device-state controlled by ARI.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Devicestates+REST+API#Asterisk12DevicestatesRESTAPI-delete
    #
    # @param [String] device_name Name of the device
    #
    # Error Responses
    #
    # 404 - Device name is missing
    # 409 - Uncontrolled device specified
    def device_states_delete(device_name)
      delete "deviceStates/#{device_name}"
    end

    # Mailboxes REST API

    # GET
    # /mailboxes
    # List[Mailbox]
    # List all mailboxes.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Mailboxes+REST+API#Asterisk12MailboxesRESTAPI-list
    def mailboxes_list
      get "mailboxes"
    end

    # GET
    # /mailboxes/:mailboxName
    # Mailbox
    # Retrieve the current state of a mailbox.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Mailboxes+REST+API#Asterisk12MailboxesRESTAPI-get
    #
    # @param [String] mailbox_name Name of the mailbox
    #
    # Error Responses
    #
    # 404 - Mailbox not found
    def mailboxes_get(mailbox_name)
      get "mailboxes/#{mailbox_name}"
    end

    # PUT
    # /mailboxes/:mailboxName
    # void
    # Change the state of a mailbox. (Note - implicitly creates the mailbox).
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Mailboxes+REST+API#Asterisk12MailboxesRESTAPI-update
    #
    # @param [String] mailbox_name Name of the mailbox
    # @param [Hash] params
    # @option params [Integer] :oldMessages *required Count of old messages in the mailbox
    # @option params [Integer] :newMessages *required Count of new messages in the mailbox
    #
    # Error Responses
    #
    # 404 - Mailbox not found
    def mailboxes_update(mailbox_name, params = {})
      put "mailboxes/#{mailbox_name}", params
    end

    # DELETE
    # /mailboxes/:mailboxName
    # void
    # Destroy a mailbox.
    #
    # @see https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Mailboxes+REST+API#Asterisk12MailboxesRESTAPI-delete
    #
    # @param [String] mailbox_name Name of the mailbox
    #
    # Error Responses
    #
    # 404 - Mailbox not found
    def mailboxes_delete(mailbox_name)
      delete "mailboxes/#{mailbox_name}"
    end

    private

      def api_call(path, args = {}, verb = "get", options = {}, &error_checking_block)
        # Setup args for make_request
        path = "/ari/#{path}" unless path =~ /^\//
        path = "/#{@prefix}#{path}" if @prefix

        options.merge!({:host => @host, :port => @port, :username => @username, :password => @password})
        # Make request via the provided service
        result = ARI.make_request path, args, verb, options

        if result.status >= 500
          error_detail = {
            :http_status => result.status.to_i,
            :body        => result.body
          }
          raise ARI::ServerError.new(result.body, error_detail)
        elsif result.status >= 400
          error_detail = {
            :http_status => result.status.to_i,
            :body        => result.body,
            :data        => ARI::JSON.load(result.body)
          }
          raise ARI::APIError.new(result.body, error_detail)
        end

        # Parse the body
        body = if result.headers["Content-Type"] && result.headers["Content-Type"].match("json")
          ARI::JSON.load result.body.to_s
        else
          result.body.to_s
        end
        # Return result
        if options[:http_component]
          result.send options[:http_component]
        else
          body
        end
      end

  end

  def self.http_service=(service)
    self.send :include, service
  end

  ARI.http_service = NetHTTPService

end