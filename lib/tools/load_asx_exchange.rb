def load_asx_exchange
	Exchange.create({name: 'ASX', description: 'Australian Securities Exchange', suffix: 'AX'})
end
