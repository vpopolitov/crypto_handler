class VideoSerializer < ActiveModel::Serializer
  attributes :value, :text, :video

  def value
    object.id
  end

  def text
    object.title
  end

  def video
    object
  end
end
