{\rtf1\ansi\ansicpg1252\cocoartf1561\cocoasubrtf200
{\fonttbl\f0\fmodern\fcharset0 Courier;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\sl280\partightenfactor0

\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2     def crypt(cipher_method, *args) #:nodoc:\
      options = default_options.merge(value: args.first).merge(args.last.is_a?(Hash) ? args.last : \{\})\
      raise ArgumentError.new('must specify a key') if options[:key].to_s.empty?\
      cipher = OpenSSL::Cipher.new(options[:algorithm])\
      cipher.send(cipher_method)\
      unless options[:insecure_mode]\
        raise ArgumentError.new("key must be #\{cipher.key_len\} bytes or longer") if options[:key].bytesize < cipher.key_len\
        raise ArgumentError.new('must specify an iv') if options[:iv].to_s.empty?\
        raise ArgumentError.new("iv must be #\{cipher.iv_len\} bytes or longer") if options[:iv].bytesize < cipher.iv_len\
      end\
      if options[:iv]\
        cipher.iv = options[:iv]\
        if options[:salt].nil?\
          # Use a non-salted cipher.\
          # This behaviour is retained for backwards compatibility. This mode\
          # is not secure and new deployments should use the :salt options\
          # wherever possible.\
          cipher.key = options[:key]\
        else\
          # Use an explicit salt (which can be persisted into a database on a\
          # per-column basis, for example). This is the preferred (and more\
          # secure) mode of operation.\
          cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(options[:key], options[:salt], options[:hmac_iterations], cipher.key_len)\
        end\
      else\
        # This is deprecated and needs to be changed.\
        cipher.pkcs5_keyivgen(options[:key])\
      end\
      yield cipher, options if block_given?\
      value = options[:value]\
      if cipher.authenticated?\
        if encryption?(cipher_method)\
          cipher.auth_data = options[:auth_data]\
        else\
          value = extract_cipher_text(options[:value])\
          cipher.auth_tag = extract_auth_tag(options[:value])\
          # auth_data must be set after auth_tag has been set when decrypting\
          # See http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-auth_data-3D\
          cipher.auth_data = options[:auth_data]\
        end\
      end\
      result = cipher.update(value)\
      result << cipher.final\
      result << cipher.auth_tag if cipher.authenticated? && encryption?(cipher_method)\
      result\
    end\
}