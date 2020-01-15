import ClientsGenerator
import ConferencesGenerator
import ParticipantsGenerator


class DataGenerator:
    def __init__(self):
        self.part_gen = ParticipantsGenerator.ParticipantsGenerator()
        self.cl_gen = ClientsGenerator.ClientsGenerator(0,self.part_gen)
        self.conf_gen = ConferencesGenerator.ConferencesGenerator(self.cl_gen)

    def make_participants(self, number):
        res = 'SET IDENTITY_INSERT Participants ON'
        for _ in range(number):
            res += '\n'
            res += self.part_gen.get_random_participant_as_sql()
        res += '\nSET IDENTITY_INSERT Participants OFF'
        return res

    def make_clients(self, number):
        res = 'SET IDENTITY_INSERT Clients ON'
        for _ in range(number):
            res+='\n'
            res += self.cl_gen.get_random_client_as_sql()
        res += '\nSET IDENTITY_INSERT Clients OFF'
        return res

    def make_conferences(self, number):
        res = ''
        for _ in range(number):
            res+='\n'
            res+=self.conf_gen.get_random_conference_as_sql()
        return res


if __name__ == '__main__':
    data_generator = DataGenerator()
    print(data_generator.make_participants(30))
    print(data_generator.make_clients(10))
    print(data_generator.make_conferences(5))
