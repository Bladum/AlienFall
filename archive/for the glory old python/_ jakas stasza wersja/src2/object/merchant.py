class Merchant(object):

    def __init__(self, args):

        self.owner = args.get('owner', 'REB')
        self.lifetime = args.get('lifetime', 12 * 4)
        self.effectiveness = args.get('effectiveness', 0.25)
