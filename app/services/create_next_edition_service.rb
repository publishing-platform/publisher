class CreateNextEditionService
  include Callable

  def initialize(current_edition:, user:)
    @current_edition = current_edition
    @user = user
  end

  def call
    raise "Can only create a next edition from a live edition" unless current_edition.live?

    current_edition.update!(current: false)
    EditDraftEditionService.call(
        next_edition, 
        user,        
        created_by: user,
        number: current_edition.document.next_edition_number,
        current: true,
        live: false,
        published_at: nil
      )
    next_edition.save!
    next_edition
  end

private

  attr_reader :current_edition, :user

  def next_edition
    @next_edition ||= current_edition.dup.tap do |e|
      e.state = :draft
    end
  end
end