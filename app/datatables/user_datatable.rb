class UserDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      id: { source: 'User.id', cond: :eq },
      name: { source: 'User.name', cond: :like },
      email: { source: 'User.email', cond: :like }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        name: record.name,
        email: record.email
      }
    end
  end

  def get_raw_records
    User.all
  end
end
