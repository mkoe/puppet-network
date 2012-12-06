#!/usr/bin/env ruby -S rspec

require 'spec_helper'

type_class = Puppet::Type.type(:network_config)

describe type_class do
  before do
    @provider_class = stub 'provider class', :name => "fake", :suitable? => true, :supports_parameter? => true
    @provider = stub 'provider', :class => @provider_class
    @provider_class.stubs(:new).returns @provider

    type_class.stubs(:defaultprovider).returns @provider_class
    type_class.stubs(:provider).returns @provider_class

    @resource = stub 'resource', :resource => nil, :provider => @provider
  end

  describe "when validating the attribute" do

    subject { type_class }

    [:name, :reconfigure].each do |param|
      it "should have the '#{param}' param" do
        subject.attrtype(param).should == :param
      end
    end

    [:ensure, :ipaddress, :netmask, :method, :family, :onboot, :options].each do |property|
      it "should have the '#{property}' property" do
        subject.attrtype(property).should == :property
      end
    end

    it "use the name parameter as the namevar" do
      subject.key_attributes.should == [:name]
    end

    describe "ensure" do
      it "should be an ensurable value" do
        subject.propertybyname(:ensure).ancestors.should be_include(Puppet::Property::Ensure)
      end
    end

    describe "options" do
      it "should be a descendant of the KeyValue property" do
        pending "on conversion to specific type"
        subject.propertybyname(:options).ancestors.should be_include(Puppet::Property::Ensure)
      end
    end
  end

  describe "when validating the attribute value" do

    subject { type_class }

    describe "ipaddress" do

      let(:address4){ '127.0.0.1' }
      let(:address6){ '::1' }

      describe "using the inet family" do

        it "should require that a passed address is a valid IPv4 address" do
          expect { subject.new(:name => 'yay', :family => :inet, :ipaddress => address4) }.to_not raise_error
        end
        it "should fail when passed an IPv6 address" do
          pending "implementation of IP address validation"
          expect { subject.new(:name => 'yay', :family => :inet, :ipaddress => address6) }.to raise_error
        end
      end

      describe "using the inet6 family" do
        it "should require that a passed address is a valid IPv6 address" do
          expect { subject.new(:name => 'yay', :family => :inet6, :ipaddress => address6) }.to_not raise_error
        end
        it "should fail when passed an IPv4 address" do
          pending "implementation of IP address validation"
          expect { subject.new(:name => 'yay', :family => :inet6, :ipaddress => address4) }.to raise_error
        end
      end

      it "should fail if a malformed address is used" do
        pending "implementation of IP address validation"
        expect { subject.new(:name => 'yay', :ipaddress => 'This is clearly not an IP address') }.to raise_error
      end
    end

    describe "netmask" do
      it "should validate a CIDR netmask"
      it "should fail if an invalid CIDR netmask is used" do
        pending "implementation of IP address validation"
        expect do
          subject.new(:name => 'yay', :netmask => 'This is clearly not a netmask')
        end.to raise_error
      end
    end

    describe "method" do
      [:static, :manual, :dhcp].each do |mth|
        it "should consider '#{mth}' a valid configuration method" do
          subject.new(:name => 'yay', :method => mth)
        end
      end
    end

    describe "family" do
      [:inet, :inet6].each do |family|
        it "should consider '#{family}' a valid address family" do
          subject.new(:name => 'yay', :family => family)
        end
      end
    end

    describe 'onboot' do
      [true, false].each do |bool|
        it "should accept '#{bool}' for onboot" do
          subject.new(:name => 'yay', :onboot => true)
        end
      end
    end

    describe 'reconfigure' do
      [true, false].each do |bool|
        it "should accept '#{bool}' for reconfigure" do
          subject.new(:name => 'yay', :reconfigure => true)
        end
      end
    end

    describe "options" do
      it "should accept an empty hash" do
        expect do
          subject.new(:name => "valid", :options => {})
        end.to_not raise_error
      end

      it "should use an empty hash as the default" do
        expect do
          subject.new(:name => "valid")
        end.to_not raise_error
      end
      it "should fail if a non-hash is passed" do
        expect do
          subject.new(:name => "valid", :options => "geese" )
        end.to raise_error
      end
    end
  end
end
