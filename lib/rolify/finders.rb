module Rolify
  module Finders
    def with_role(role_name, resource = nil)
      strict = self.strict_rolify and resource and resource != :any
      self.adapter.scope(
        self,
        { :name => role_name, :resource => resource },
        strict
      )
    end

    def without_role(role_name, resource = nil)
      self.adapter.all_except(self, self.with_role(role_name, resource))
    end

    def with_all_roles(*args)
      intersect_ars(parse_args(args, :split)).uniq
    end

    def with_any_role(*args)
      union_ars(parse_args(args, :join)).uniq
    end
  end

  private

  def parse_args(args, mode, &block)
    normalize_args(args, mode).map do |arg|
      self.with_role(arg[:name], arg[:resource]).tap do |users_to_add|
        block.call(users_to_add) if block
      end
    end
  end

  # In: [:a, "b", { name: :c, resource: :d }]
  # Out: [{ name: [:a, "b"] }, { name: :c, resource: :d }]
  def normalize_args(args, mode)
    groups = args.group_by(&:class)
    unless groups.keys.all? { |type| [Hash, Symbol, String].include?(type) }
      raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
    end

    normalized = [groups[Hash]]
    sym_str_args = [groups[Symbol], groups[String]].flatten.compact
    case mode
    when :join
      normalized += [{ name: sym_str_args }] unless sym_str_args.empty?
    when :split
      normalized += sym_str_args.map { |arg| { name: arg } }
    end

    normalized.flatten.compact
  end


  def intersect_ars(ars)
    query = ars.map(&:to_sql).join(" INTERSECT ")
    from("(#{query}) AS #{table_name}")
  end

  # http://stackoverflow.com/a/16868735/1202488
  def union_ars(ars)
    query = ars.map(&:to_sql).join(" UNION ")
    from("(#{query}) AS #{table_name}")
  end
end
