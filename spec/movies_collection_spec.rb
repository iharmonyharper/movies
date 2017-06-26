module Cinematic
  describe 'Movies collection' do
    let(:movies) do
      [
          {title: 'The Terminator', year: 2000, genre: 'Action,Sci-Fi', rating: 8.2, duration: '90min', actors: ''},
          {title: 'The General', year: 1921, genre: 'Action,Adventure,Comedy', rating: 8.2, actors: ''},
          {title: 'The Kid', year: 1921, genre: 'Comedy,Drama,Family', rating: 8.2, duration: '90min', actors: ''},
          {title: 'The Wolf of Wall Street', year: 2000, genre: 'Comedy,Crime', rating: 8.2, duration: '90min', actors: ''},
          {title: 'Nausicaä of the Valley of the Wind', year: 2000, genre: 'Adventure,Fantasy', rating: 8.2, duration: '90min', actors: ''},
          {title: '3 Idiots', year: 2000, genre: 'Comedy,Drama', rating: 8.2, duration: '90min', actors: ''},
          {title: 'The Thing', year: 1982, genre: 'Horror', rating: 8.2, duration: '90min', actors: ''},
          {title: 'Rocky', year: 2000, genre: 'Drama', rating: 8.2, duration: '90min', actors: ''}
      ]
    end

    let(:collection) {MovieCollection.new(title: 'TestCollection', collection_raw_data: movies, movie_class: Movies::Movie)}

    context "#map" do
      subject {collection.all.map(&block)}
      let(:block) {:title}
      it '#map simple' do
        expect(subject).to eq(movies.map {|h| h[:title]})
      end
      let(:block) {Proc.new {|x| x.title}}
      it '#map with block' do
        expect(subject).to eq(movies.map {|h| h[:title]})
      end
    end

    context '#sort' do
      subject {collection.all.sort}
      it 'sorts collection' do
        expect(subject.map(&:title)).to eq(['3 Idiots',
                                            'Nausicaä of the Valley of the Wind',
                                            'Rocky',
                                            'The General',
                                            'The Kid',
                                            'The Terminator',
                                            'The Thing',
                                            'The Wolf of Wall Street'])
      end
    end


    context '#select' do
      subject {collection.all.select(&block)}
      let(:block) {Proc.new {|x| x.year.even?}}
      it '#select with block' do
        expect(subject.count).to eq(6)
      end
    end

    context '#reject' do
      subject {collection.all.reject(&block)}
      let(:block) {Proc.new {|x| x.year.even?}}
      it '#reject with block' do
        expect(subject.count).to eq(2)
      end
    end

    context '#count' do
      subject {collection.all.count(&block)}
      let(:block) {Proc.new {|x| x.year.even?}}
      it '#count with block' do
        expect(subject).to eq(6)
      end
    end

    context '#reduce' do
      subject {collection.all.reduce(0, &block)}
      let(:block) {Proc.new {|sum, x| sum += x.year}}
      it 'return sum of years' do
        expect(subject).to eq(15824)
      end
    end
  end
end

