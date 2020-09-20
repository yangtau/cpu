s = '''
'''
xs = [x for x in s.split('\n') if x != '']
comments = [x.split("//")[1] for x in xs]
xs = [s.split('=')[1].split(';')[0].replace('_', '')[4:] for s in xs]

ys = ["%08x"%(int(x, 2)) for x in xs]

for i in range(len(ys)):
	print("assign rom[6'h0{}]=32'h{}; //{}".format(i+1, ys[i], comments[i]))