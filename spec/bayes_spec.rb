require File.join(Dir.pwd, 'spec', 'spec_helper.rb')

describe Reclassifier::Bayes do
	describe "classifications" do
    it "should return the classifications" do
      subject = described_class.new(:interesting, :uninteresting)

      subject.classifications.sort.should eq([:interesting, :uninteresting])
    end
	end

  describe "train" do
    it "should raise an UnknownClassificationError if the specified classification hasn't been added" do
      expect {subject.train(:blargle, '')}.to raise_error(Reclassifier::UnknownClassificationError)
    end

    it "should train the classifier to the (classification, document) pair" do
      subject = described_class.new(:in_china, :not_in_china)

      subject.train(:in_china, 'Chinese Beijing Chinese')
      subject.train(:in_china, 'Chinese Chinese Shanghai')
      subject.train(:in_china, 'Chinese Macao')
      subject.train(:not_in_china, 'Tokyo Japan Chinese')

      subject.classify('Chinese Chinese Chinese Tokyo Japan').should eq(:in_china)
    end
  end

  describe "untrain" do
    it "should raise an UnknownClassificationError if the specified classification hasn't been added" do
      expect {subject.untrain(:blargle, '')}.to raise_error(Reclassifier::UnknownClassificationError)
    end

    it "should untrain the classifier against the (classification, document) pair" do
      subject = described_class.new(:in_china, :not_in_china)

      subject.train(:in_china, 'Chinese Chinese')
      subject.train(:not_in_china, 'Chinese Macao')

      subject.classify('Chinese').should eq(:in_china)

      subject.untrain(:in_china, 'Chinese Chinese')

      subject.classify('Chinese').should eq(:not_in_china)
    end
  end

  describe "calculate_scores" do
    it "should return a score hash with the correct scores" do
      subject = described_class.new(:in_china, :not_in_china)

      subject.train(:in_china, 'Chinese Beijing Chinese')
      subject.train(:in_china, 'Chinese Chinese Shanghai')
      subject.train(:in_china, 'Chinese Macao')
      subject.train(:not_in_china, 'Tokyo Japan Chinese')

      scores = subject.calculate_scores('Chinese Chinese Chinese Tokyo Japan')

      scores[:in_china].should eq(-8.107690312843907)
      scores[:not_in_china].should eq(-8.906681345001262)
    end
  end

  describe "add_classification" do
    it "should add the classification to the set of classifications" do
      subject.classifications.should be_empty

      subject.add_classification(:niner)

      subject.classifications.should eq([:niner])
    end

    it "should return the classification" do
      subject.add_classification(:niner).should eq(:niner)
    end
  end

  describe "remove_classification" do
    it "should remove the classification from the set of classifications" do
      subject.add_classification(:niner)

      subject.remove_classification(:niner)

      subject.classifications.should be_empty
    end

    it "should return the classification" do
      subject.add_classification(:niner)

      subject.remove_classification(:niner).should eq(:niner)
    end

    it "should return nil if the classification didn't exist" do
      subject.remove_classification(:niner).should be(nil)
    end
  end
end
