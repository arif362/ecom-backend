module Util
  def sql_conjunction (type, sql, str)
    return sql.present? ? " #{type} #{str}" : str
  end
end