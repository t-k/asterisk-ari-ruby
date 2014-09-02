require "spec_helper"

describe ARI::Client do
  before(:each) do
    @client ||= ARI::Client.new({
      :host     => SPEC_CONF["host"],
      :port     => SPEC_CONF["port"],
      :username => SPEC_CONF["username"],
      :password => SPEC_CONF["password"]
    })
  end

  it "has an attr_reader for host" do
    @client.host.should == SPEC_CONF["host"]
  end

  it "has an attr_reader for port" do
    @client.port.should == SPEC_CONF["port"]
  end

  it "has an attr_reader for username" do
    @client.username.should == SPEC_CONF["username"]
  end

  it "has an attr_reader for password" do
    @client.password.should == SPEC_CONF["password"]
  end

  context "api request", :vcr do
    describe "#asterisk_get_info" do
      it "returns data" do
        result = @client.asterisk_get_info
        result["build"].nil?.should == false
      end
    end
    context "global_var" do
      describe "#asterisk_set_global_var and #asterisk_get_global_var" do
        it "returns data" do
          key = "FOO"
          value = "BAR"
          result = @client.asterisk_set_global_var({:variable => key, :value => value})
          result.should == ""
          result = @client.asterisk_get_global_var({:variable => key})
          result["value"].should == value
        end
      end
    end

    describe "#bridges_list" do
      it "returns data" do
        result = @client.bridges_list
        result.is_a?(Array).should == true
      end
    end

    describe "#bridges_create" do
      it "returns data" do
        bridge_id = "1409571774"
        bridge_name = "bridge_name"
        bridge_type = "mixing"
        result = @client.bridges_create({:type => "mixing", :bridgeId => bridge_id, :name => bridge_name})
        result["bridge_type"].should == bridge_type
        result["id"].should == bridge_id
        result["name"].should == bridge_name

        new_bridge_type = "holding"
        result = @client.bridges_create_or_update_with_id(bridge_id, {:type => new_bridge_type})
        result["bridge_type"].should == new_bridge_type
        result["id"].should == bridge_id
        # result["name"].should == bridge_name

        result = @client.bridges_get(bridge_id)
        result["bridge_type"].should == new_bridge_type
        result["id"].should == bridge_id
        # result["name"].should == bridge_name

        result = @client.bridges_destroy(bridge_id)
        result.should == ""
      end
    end

    describe "#channels_list" do
      it "returns data" do
        result = @client.channels_list
        result.is_a?(Array).should == true
      end
    end

    describe "#channels_get" do
      it "returns data" do
        id = "1409619856.0"
        result = @client.channels_get(id)
        result["id"].should == id
      end
    end

    describe "#channels_record" do
      it "returns data" do
        id = "1409624128.10"
        name = "/tmp/record"
        format = "sln192"
        result = @client.channels_record(id, {:name => name, :format => format, :maxDurationSeconds => 10})
        result["name"].should == name
        result["format"].should == format
      end
    end

    describe "#channels_set_channel_var" do
      it "returns data" do
        id = "1409624128.10"
        key = "FOO"
        value = "BAR"
        result = @client.channels_set_channel_var(id, {:variable => key, :value => value})
        result.should == ""
        result = @client.channels_get_channel_var(id, {:variable => key})
        result["value"].should == value
      end
    end

    describe "#channels_hangup" do
      it "returns data" do
        id = "1409619856.0"
        result = @client.channels_hangup(id)
        result.should == ""
      end
    end

    describe "#endpoints_list" do
      it "returns data" do
        result = @client.endpoints_list
        result.is_a?(Array).should == true
      end
    end

    describe "#endpoints_send_message" do
      it "returns data" do
        result = @client.endpoints_send_message({:to => "SIP", :from => "IAX2", :body => "body"})
        result.should == ""
      end
    end

    describe "#endpoints_list_by_tech" do
      it "returns data" do
        result = @client.endpoints_list_by_tech("SIP")
        result.is_a?(Array).should == true
      end
    end

    describe "#events_user_event" do
      it "returns data" do
        result = @client.events_user_event("ApplicationReplaced", {application: "hello-world"})
        result.should == ""
      end
    end

    describe "#recordings_list_stored" do
      it "returns data" do
        result = @client.recordings_list_stored
        result.is_a?(Array).should == true
      end
    end

    describe "#recordings_get_stored" do
      it "returns data" do
        name = "/tmp/record"
        result = @client.recordings_get_stored(name)
        result[0]["name"].should == "tmp/record"
      end
    end

    describe "#recordings_get_live" do
      it "returns data" do
        name = "record2"
        result = @client.recordings_get_live(name)
        result["name"].should == name
      end
    end

    describe "#recordings_pause" do
      it "returns data" do
        name = "record2"
        result = @client.recordings_pause(name)
        result.should == ""
        result = @client.recordings_unpause(name)
        result.should == ""
      end
    end

    describe "#recordings_mute" do
      it "returns data" do
        name = "record2"
        result = @client.recordings_mute(name)
        result.should == ""
        result = @client.recordings_unmute(name)
        result.should == ""
      end
    end

    describe "#recordings_cancel" do
      it "returns data" do
        name = "record2"
        result = @client.recordings_cancel(name)
        result.should == ""
      end
    end

    describe "#sounds_list" do
      context "without params" do
        it "returns data" do
          result = @client.sounds_list
          result.is_a?(Array).should == true
        end
      end
      context "with params" do
        it "returns data" do
          result = @client.sounds_list({:lang => "en"})
          result.is_a?(Array).should == true
        end
      end
    end

    describe "#sounds_get" do
      it "returns data" do
        id = "vm-torerecord"
        result = @client.sounds_get(id)
        result["id"].should == id
        result["text"].nil?.should == false
        result["formats"].nil?.should == false
      end
    end

    describe "#applications_list" do
      it "returns data" do
        result = @client.applications_list
        result.is_a?(Array).should == true
      end
    end

    describe "#applications_get" do
      it "returns data" do
        name = "hello-world"
        result = @client.applications_get name
        result["name"].should == name
      end
    end

    describe "#applications_subscribe" do
      it "returns data" do
        name = "hello-world"
        source = "channel:1409624128.10"
        result = @client.applications_subscribe(name, {:eventSource => source})
        result["name"].should == name
        result = @client.applications_unsubscribe(name, {:eventSource => source})
        result["name"].should == name
      end
    end

    describe "#device_states_list" do
      it "returns data" do
        result = @client.device_states_list
        result.is_a?(Array).should == true
      end
    end

  end

end