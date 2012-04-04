module Rolify
  module Utils
    def deprecate(old_method, new_method)
      define_method(old_method) do |*args, &block|
        warn "[DEPRECATION] #{caller.first}: `#{old_method}` is deprecated.  Please use `#{new_method}` instead."
        send(new_method, *args, &block)
      end
    end
  end
end