require_relative './spec_helper'

require 'focuslight/validator'

describe Focuslight::Validator do
  describe '.rule' do
    it 'returns not_blank predefined rule' do
      r = Focuslight::Validator.rule(:not_blank)
      expect(r.check(nil)).to be_false
      expect(r.check("")).to be_false
      expect(r.check(" ")).to be_false
      expect(r.check("a")).to be_true

      expect(r.format("a")).to eql("a")
      expect(r.format(" a ")).to eql("a")

      expect(r.error_message(:col)).to eql("col: missing or blank")
    end

    it 'returns choice predefined rule' do
      r1 = Focuslight::Validator.rule(:choice, "x", "y", "z")
      expect(r1.check("a")).to be_false
      expect(r1.check("x")).to be_true
      expect(r1.check("z")).to be_true

      expect(r1.format("x")).to eql("x")

      expect(r1.error_message(:col)).to eql("col: invalid value")

      r2 = Focuslight::Validator.rule(:choice, ["x", "y", "z"])
      expect(r2.check("a")).to be_false
      expect(r2.check("x")).to be_true
      expect(r2.check("z")).to be_true

      expect(r2.format("x")).to eql("x")
    end

    it 'returns int predefined rule' do
      r = Focuslight::Validator.rule(:int)
      expect(r.check("0")).to be_true
      expect(r.check("100")).to be_true
      expect(r.check("-21")).to be_true
      expect(r.check("1.0")).to be_false
      expect(r.check("-3e10")).to be_false
      expect(r.check("xyz")).to be_false

      expect(r.format("0")).to eql(0)
      expect(r.format("100")).to eql(100)
      expect(r.format("-21")).to eql(-21)

      expect(r.error_message(:col)).to eql("col: invalid integer")
    end

    it 'returns uint predefined rule' do
      r = Focuslight::Validator.rule(:uint)
      expect(r.check("0")).to be_true
      expect(r.check("100")).to be_true
      expect(r.check("-21")).to be_false
      expect(r.check("1.0")).to be_false
      expect(r.check("-3e10")).to be_false
      expect(r.check("xyz")).to be_false

      expect(r.format("0")).to eql(0)
      expect(r.format("100")).to eql(100)

      expect(r.error_message(:col)).to eql("col: invalid integer (>= 0)")
    end

    it 'returns natural predefined rule' do
      r = Focuslight::Validator.rule(:natural)
      expect(r.check("0")).to be_false
      expect(r.check("100")).to be_true
      expect(r.check("-21")).to be_false
      expect(r.check("1.0")).to be_false
      expect(r.check("-3e10")).to be_false
      expect(r.check("xyz")).to be_false

      expect(r.format("0")).to eql(0)
      expect(r.format("100")).to eql(100)

      expect(r.error_message(:col)).to eql("col: invalid integer (>= 1)")
    end

    it 'returns float/double/real predefined rule' do
      r1 = Focuslight::Validator.rule(:float)
      r2 = Focuslight::Validator.rule(:double)
      r3 = Focuslight::Validator.rule(:real)
      [r1, r2, r3].each do |r|
        expect(r.check("0")).to be_true
        expect(r.check("0.0")).to be_true
        expect(r.check("1.0")).to be_true
        expect(r.check("1e+10")).to be_true
        expect(r.check("2e-10")).to be_true
        expect(r.check("-2e-10")).to be_true
        expect(r.check("e")).to be_false
        expect(r.check("xyz")).to be_false
        expect(r.check("")).to be_false

        expect(r.format("0")).to eql(0.0)
        expect(r.format("0.0")).to eql(0.0)
        expect(r.format("1.0")).to eql(1.0)
        expect(r.format("1e+10")).to eql(1e+10)
        expect(r.format("2e-10")).to eql(2e-10)
        expect(r.format("-2e-10")).to eql(-2e-10)

        expect(r.error_message(:col)).to eql("col: invalid floating point num")
      end
    end

    it 'returns int_range predefined rule' do
      r1 = Focuslight::Validator.rule(:int_range, 0..3)
      expect(r1.check("0")).to be_true
      expect(r1.check("1")).to be_true
      expect(r1.check("3")).to be_true
      expect(r1.check("-1")).to be_false

      expect(r1.format("0")).to eql(0)

      expect(r1.error_message(:col)).to eql("col: invalid number in range 0..3")

      r2 = Focuslight::Validator.rule(:int_range, 1..3)
      expect(r2.check("0")).to be_false
      expect(r2.check("1")).to be_true
      expect(r2.check("3")).to be_true
      expect(r2.check("-1")).to be_false

      expect(r2.format("1")).to eql(1)

      expect(r2.error_message(:col)).to eql("col: invalid number in range 1..3")
    end

    it 'returns rule instance whatever we want with "lambda" rule name' do
      r = Focuslight::Validator.rule(:lambda, ->(v){ v == 'kazeburo' }, "kazeburo only permitted", :to_sym)
      expect(r.check("kazeburo")).to be_true
      expect(r.check(" ")).to be_false
      expect(r.check("tagomoris")).to be_false

      expect(r.format("kazeburo")).to eql(:kazeburo)

      expect(r.error_message(:col)).to eql("col: kazeburo only permitted")
    end
  end
end
