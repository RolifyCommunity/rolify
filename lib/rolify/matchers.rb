RSpec::Matchers.define :have_role do |*args|
  match do |resource|
    resource.has_role?(*args)
  end

  failure_message_for_should do |resource|
    "expected to have role #{args.map(&:inspect).join(" ")}"
  end

  failure_message_for_should_not do |resource|
    "expected not to have role #{args.map(&:inspect).join(" ")}"
  end
end
