module PolyPseudo
  class Identity
    include PolyPseudo::PseudoId

    # @param [PolyPseudo::Key] key
    def decrypt(key)
      PolyPseudo.init!

      public_key = key.ec.public_key

      raise "Invalid key for decryption" if point_3 != public_key

      private_key = key.ec.private_key

      identity_point = point_1
          .mul(private_key)
          .invert!
          .add(point_2)
          .make_affine!

      decoded = Util.oaep_decode(identity_point.x.to_s(2).rjust(40, "\x00"))
      @identity = decoded.slice(3, decoded[2].ord).force_encoding("UTF-8")
    end

    def identity
      @identity || raise('Identity not decrypted yet. call .decrypt first')
    end

    alias_method :pseudo_id, :identity
  end
end
