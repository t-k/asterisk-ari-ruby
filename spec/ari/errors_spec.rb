require "spec_helper"

describe ARI::Error do
  it "is a ARI::ARIError" do
    ARI::Error.new(nil, nil).should be_a(ARI::ARIError)
  end
end

describe ARI::ARIError do
  it "is a StandardError" do
    ARI::ARIError.new.should be_a(StandardError)
  end
end

describe ARI::APIError do
  it "is a ARI::APIError" do
    ARI::APIError.new({}).should be_a(ARI::APIError)
  end
end

describe ARI::ServerError do
  it "is a ARI::Error" do
    ARI::ServerError.new(nil, nil).should be_a(ARI::ServerError)
  end
end