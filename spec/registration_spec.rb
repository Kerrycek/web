require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

describe "vpsFree.cz registration form" do
	#URL = 'https://dev.vpsfree.cz'
	#URL = 'https://vpsfree.cz'
	URL = 'http://vpsfree-ng.cz'

	ENTITIES = {
			fyzicka: %i(login first_name surname birth address city zip country email),
			pravnicka: %i(login first_name surname birth org_name ic address city zip country email),
	}

  BASE_DATA = {
      login: 'testovac',
      first_name: 'Testik',
      surname: 'Testovic',
      birth: 1990,
      address: 'Na Ulici 173',
      city: 'Ve Meste',
      zip: '12345',
      country: 'Ve State',
      email: 'aither@havefun.cz',
			org_name: 'VeryCorp',
			ic: 12365498,
  }

  FIELD_TESTS = {
      # field => { true => [values that pass], false => [values that do not pass] }
      login: {
          false => [
              'a',
              'aa',
              ' ' * 3,
              'Илья́',
              '!@#$%',
              '---',
              '...',
              'a' * 64,
          ],
          true => [
              'aaa',
              'aa-bb',
              'aa.bb',
              'aaa12',
              '1234',
              'a' * 63,
          ],
      },
      first_name: {
          false => [
              'a',
              ' ' * 3,
          ],
          true => [
              'aa',
              'aaa',
              'Илья́',
              'Алекса́ндрович',
              '立显荣朝士',
          ],
      },
      surname: {
          false => [
              'a',
              ' ' * 3,
          ],
          true => [
              'aa',
              'aaa',
              'Ежо́в',
              '文方运际祥',
          ],
      },
      birth: {
          false => [
              ' ' * 3,
              'abcd',
              '12',
              '123',
              '1900',
              '2016',
          ],
          true => [
              '1999',
          ],
      },
			address: {
					false => [
							' ' * 3,
							'a',
							'Aa',
							'Ulice',
							'Na Ulici',
					],
					true => [
							'Ulice 4',
							'Ulice 987',
							'Na Ulici 123',
					],
			},
      city: {
          false => [
              ' ' * 3,
              '123 456',
              'a',
          ],
          true => [
              'Aš',
              'Cheb',
              'Valašské Meziříčí',
              '東京',
          ],
      },
      zip: {
          false => [
              ' ' * 5,
              'abcd',
              '12',
              '1234',
              '123456',
          ],
          true => [
              '12345',
              '123 45',
          ],
      },
      email: {
          false => [
              'aa',
              'aaa',
              '  @   .  ',
              '@tld.cz',
              '   @tld.cz',
              'test@@tld.cz',
              'test @tld.cz',
              'test @ tld.cz',
              'test@tld..cz',
              'test..dva@tld.cz',
          ],
          true => [
              'test@tld.cz',
              'test.dva@tld.cz',
              'test.dva.tri@tld.cz',
              'test+dva@tld.cz',
              'test!dva@tld.cz',
              'test.dva@tld-dash.cz',
              'test22@tld.cz',
              'test.22@tld.cz',
              '22test@tld.cz',
          ],
      },
			org_name: {
					false => [
							' ' * 3,
							'A',
							'Aa',
					],
					true => [
							'Aaa',
							'Very Corp',
							'Very Corp, s.r.o',
							'Very Corp, a.s.',
							'Super Corp 123',
					],
			},
			ic: {
					false => [
							' ' * 3,
							'a',
							'abc',
							'abc123',
							'123abc',
							'12a345',
							'12',
							'123',
							'1234',
					],
					true => [
							'123456',
							'123 456',
							'123 456789',
					],
			},
  }

  before(:all) do
    @driver = Selenium::WebDriver.for(:firefox)
    @driver.manage.timeouts.implicit_wait = 5
  end

  after(:all) do
    @driver.quit
  end

  before(:each) do
    enter
  end

  def enter
    @driver.get("#{URL}/prihlaska/")
  end

	def select_entity(e)
    select = Selenium::WebDriver::Support::Select.new(
        @driver.find_element(:id, 'entity_type')
    )
    select.select_by(:value, e.to_s)
		sleep(1)
	end

	def self.get_field_data(fields)
		Hash[ BASE_DATA.clone.select { |k, v| fields.include?(k) } ]
	end	

  def write_fields(fields)
    fields.each do |k, v|
      @driver.find_element(:id, k.to_s).send_keys(v)
    end
  end

	def select_choices
		%i(distribution location currency).each do |f|
			select = Selenium::WebDriver::Support::Select.new(
					@driver.find_element(:id, f.to_s)
			)
			select.select_by(:index, 1)
		end
	end

  # Submit the form
  def submit
    button = @driver.find_element(:id, "send")
    @driver.action.move_to(button).perform
    sleep(0.1)
    button.click
    sleep(2)
  end

  def reset
    enter
  end

  def mock
    @driver.execute_script(<<END
        $('form').append(
          '<input type="hidden" id="_mock" name="_mock" value="1">'
        );
END
    )
  end

  def expect_ok
    #expect do
    #  @driver.find_element(:id, f)
    #end.to raise_error(Selenium::WebDriver::Error::NoSuchElementError)

    expect(
        @driver.find_element(:css, 'h1').text
    ).to eq('Přihláška přijata, děkujeme!')
  end

  def get_classes(field)
    @driver.find_element(:id, field.to_s).attribute('class').split(/\s+/)
  end
 
	ENTITIES.each do |entity, fields|
		it 'has required fields' do
			select_entity(entity)
			submit

			fields.each do |v|
				expect(get_classes(v)).to include('error')
			end

			%i(how note).each do |v|
				expect(get_classes(v)).not_to include('error')
			end
		end

		fields.each do |f|
			next unless FIELD_TESTS.include?(f)

			FIELD_TESTS[f].each do |pass, values|
				values.each do |v|
					data = get_field_data(fields)

					it "#{pass ? 'accepts' : 'rejects'} #{f} = '#{v}'" do
						data[f] = v
						select_entity(entity)
						write_fields(data)
						select_choices
						mock
						submit

						if pass      
							expect_ok

						else
							expect(get_classes(f)).to include('error')
						end
					end
				end
			end
		end

		it 'validates distribution'
		it 'validates location'
		it 'validates currency'
		
		it 'can be submitted' do
			select_entity(entity)
			write_fields(self.class.get_field_data(fields))
			select_choices
			submit

			expect_ok
		end
	end
end
