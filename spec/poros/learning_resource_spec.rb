require 'rails_helper'

RSpec.describe 'Learning Resource Poro' do
  describe 'Learning Resource Object' do
    it 'has attributes' do
      resource = LearningResource.new('laos', { id: { videoId: 'video id' }, snippet: { title: 'title' } },
                                      [{ description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } },
                                       { description: 'description', urls: { raw: 'raw' } }])

      expect(resource.country).to eq('laos')
      expect(resource.video_id).to eq('video id')
      expect(resource.video_title).to eq('title')
      expect(resource.id).to eq('null')
      expect(resource.images_formatted).to be_a(Array)
    end
  end
end
