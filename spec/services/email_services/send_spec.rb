# frozen_string_literal: true

require "spec_helper"

describe EmailServices::Send do
  let(:email) do
    create(
      :email,
      to: "foo@bar.com",
      data: "from: contact@foo.com\nto: foo@bar.com\n\nMy original data"
    )
  end
  let(:send) { EmailServices::Send.call(email: email) }

  it "should open an smtp connection to postfix port 25" do
    expect(Net::SMTP).to receive(:start).with("postfix", 25)

    send
  end

  it "should send an email with a return-path" do
    smtp = double
    expect_any_instance_of(Delivery).to receive(:return_path)
      .and_return("bounce-address@cuttlefish.io")
    expect(smtp).to receive(:send_message).with(
      anything,
      "bounce-address@cuttlefish.io",
      anything
    ).and_return(double(message: ""))
    expect(Net::SMTP).to receive(:start).and_yield(smtp)

    send
  end

  it "should send an email to foo@bar.com" do
    smtp = double
    expect(smtp).to receive(:send_message).with(
      anything,
      anything,
      ["foo@bar.com"]
    ).and_return(double(message: ""))
    expect(Net::SMTP).to receive(:start).and_yield(smtp)

    send
  end

  it "should use data to figure out what to send" do
    smtp = double
    filtered_mail = Mail.new do
      body "My altered data"
    end
    allow_any_instance_of(Filters::Master).to receive(:filter_mail)
      .and_return(filtered_mail)
    expect(smtp).to receive(:send_message).with(
      filtered_mail.to_s,
      anything,
      anything
    ).and_return(double(message: ""))
    expect(Net::SMTP).to receive(:start).and_yield(smtp)

    send
  end

  it "should set the postfix queue id on the deliveries based on " \
     "the response from the server" do
    response = double(message: "250 2.0.0 Ok: queued as A123")
    smtp = double(send_message: response)
    allow(Net::SMTP).to receive(:start).and_yield(smtp)

    send

    email.deliveries.each { |d| expect(d.postfix_queue_id).to eq "A123" }
  end

  it "should ignore response from server that doesn't include a queue id" do
    response = double(message: "250 250 Message accepted")
    smtp = double(send_message: response)
    allow(Net::SMTP).to receive(:start).and_yield(smtp)

    send

    email.deliveries.each { |d| expect(d.postfix_queue_id).to be_nil }
  end

  context "deliveries is empty" do
    before :each do
      allow_any_instance_of(Delivery).to receive(:send?).and_return(false)
    end

    it "should send no emails" do
      # TODO: Ideally it shouldn't open a connection to the smtp server
      smtp = double
      expect(smtp).to_not receive(:send_message)
      allow(Net::SMTP).to receive(:start).and_yield(smtp)

      send
    end
  end

  context "don't actually send anything" do
    before :each do
      smtp = double(send_message: double(message: ""))
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
    end

    it "should record to which destinations the email has been sent" do
      expect(email.deliveries.first).to_not be_sent
    end

    it "should record to which destinations the email has been sent" do
      send

      expect(email.deliveries.first).to be_sent
    end

    it "should record that the deliveries are being open tracked" do
      send

      expect(email.deliveries.first).to be_open_tracked
    end

    context "app has disabled open tracking" do
      before(:each) do
        email.app.update_attributes(open_tracking_enabled: false)
      end

      it "should record that the deliveries are not being open tracked" do
        send

        expect(email.deliveries.first).to_not be_open_tracked
      end
    end
  end
end
