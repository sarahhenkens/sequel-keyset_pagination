# frozen_string_literal: true

DB.drop_table? :keyset
DB.create_table :keyset do
  primary_key :id
  integer :a, null: false
  integer :b, null: false
  text :name, null: false
end

class KeysetModel < Sequel::Model(:keyset)
end

describe Sequel::KeysetPagination do
  before {
    data = [
      { id: 1,  a: 1, b: 1, name: "gerard" },
      { id: 2,  a: 1, b: 2, name: "angela" },
      { id: 3,  a: 1, b: 3, name: "dorien" },
      { id: 4,  a: 2, b: 1, name: "franky" },
      { id: 5,  a: 2, b: 2, name: "benzod" },
      { id: 6,  a: 3, b: 1, name: "johnny" },
      { id: 7,  a: 4, b: 1, name: "heaven" },
      { id: 8,  a: 4, b: 2, name: "easter" },
      { id: 9,  a: 4, b: 3, name: "ingrid" },
      { id: 10, a: 5, b: 1, name: "ceasar" }
    ]
    DB[:keyset].multi_insert(data)
  }

  context "without cursors" do
    it "raises an aregument error with a helpful message" do
      expect {
        KeysetModel.order(:id).seek
      }.to raise_error ArgumentError, "`before` or `after` is required"
    end
  end

  context "without an order" do
    it "raises an error with a helpful message" do
      expect {
        KeysetModel.dataset.seek(before: 1)
      }.to raise_error StandardError, "cannot call #seek on a dataset with no order"
    end
  end

  context "without an incorrect number cursor values" do
    context "for the `before` cursor" do
      it "raises an error with a helpful message" do
        expect {
          KeysetModel.dataset.order(:id).seek(before: [1, 5])
        }.to raise_error StandardError, "The `before` cursor has the wrong number of values. Expected 1, received 2."
      end
    end
    context "for the `after` cursor" do
      it "raises an error with a helpful message" do
        expect {
          KeysetModel.dataset.order(:id, :bar, :foo).seek(after: [1])
        }.to raise_error StandardError, "The `after` cursor has the wrong number of values. Expected 3, received 1."
      end
    end
  end

  context "with single value cursor and a limit" do
    it "generates the correct SQL syntax" do
      result = KeysetModel.order(:id).limit(5).seek(before: 10, after: 5).sql
      expected = 'SELECT * FROM "keyset" WHERE (("id" > 5) AND ("id" < 10)) ORDER BY "id" LIMIT 5'
      expect(result).to eq expected
    end
  end

  context "sorted on primary key without specifying a direction" do
    subject { KeysetModel.order(:id) }

    context "seek on `after` set to 7" do
      it "returns only the last 3 records not including 7" do
        results = subject.seek(after: 7).map(:id)
        expect(results).to eq [8, 9, 10]
      end
    end

    context "seek on `after` set to 3 with a limit of 2, using the array syntax" do
      it "returns the correct 2 records" do
        results = subject.seek(after: [3]).limit(2).map(:id)
        expect(results).to eq [4, 5]
      end
    end
  end

  context "sorted on primary key in asc order" do
    subject { KeysetModel.order(Sequel.asc(:id)) }

    context "seek on `before` set to 3" do
      it "returns the first 2 records in the dataset in asc order" do
        results = subject.seek(before: 3).map(:id)
        expect(results).to eq [1, 2]
      end
    end

    context "seek with both before and after configured" do
      it "returns the results between the cursors" do
        results = subject.seek(after: 2, before: 7).map(:id)
        expect(results).to eq [3, 4, 5, 6]
      end
    end
  end

  context "sorted on primary key in desc order" do
    subject { KeysetModel.order(Sequel.desc(:id)) }

    context "seek on `after` set to 5" do
      it "returns the first 4 records in the dataset in descending order" do
        results = subject.seek(after: 5).map(:id)
        expect(results).to eq [4, 3, 2, 1]
      end
    end
  end

  context "if an QualifiedIdentifier is used for sorting" do
    subject { KeysetModel.order(:keyset[:id]) }

    it "supports the order type still seeks correctly" do
      results = subject.seek(after: 2).limit(1).map(:id)
      expect(results).to eq [3]
    end
  end

  context "sorting on two non-nullable integer columns in the same direction" do
    subject { KeysetModel.order(:a, :b) }

    context "When the cursor is set to a row that has more items in the same primary set" do
      it "still considers the other items in that primary set before going to the next set" do
        results = subject.seek(after: [2, 1]).limit(3).map { |r| "#{r.a}-#{r.b}" }
        expect(results).to eq ["2-2", "3-1", "4-1"]
      end
    end

    context "when we reverse the order while applying the `after` cursor" do
      it "still considers the other items in that primary set before going to the next set" do
        results = subject.reverse.seek(after: [4, 2]).limit(4).map { |r| "#{r.a}-#{r.b}" }
        expect(results).to eq ["4-1", "3-1", "2-2", "2-1"]
      end
    end

    context "With the `before` cursor set at the second item of the second primary set" do
      it "returns the entire first plus the first item of the second set" do
        results = subject.seek(before: [2, 2]).map { |r| "#{r.a}-#{r.b}" }
        expect(results).to eq ["1-1", "1-2", "1-3", "2-1"]
      end
    end
  end

  context "sorting on a single text field" do
    subject { KeysetModel.order(Sequel.asc(:name)) }

    context "Using both `after` and `before` which exist in the dataset" do
      it "the cursor names are not considered inclusive in the result set." do
        results = subject.seek(after: "dorien", before: "heaven").map(:name)
        expect(results).to eq ["easter", "franky", "gerard"]
      end
    end
  end
end
