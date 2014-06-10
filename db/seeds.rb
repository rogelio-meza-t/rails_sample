# encoding: utf-8

Currency.create({name: 'US Dollar', code: 'USD', separator: '.', delimiter: ','})
Currency.create({name: 'Chilean Peso', code: 'CLP', separator: ',', delimiter: '.'})
Currency.create({name: 'Euro', code: 'EUR', separator: '.', delimiter: ','})
Currency.create({name: 'Mexican Peso', code: 'MXN', separator: ',', delimiter: '.'})

path11_tours = TourOperator.create(
  name:               'Zion Adventures',
  logo:               'https://dl.dropbox.com/u/1130242/TeamZionAdventures.jpg',
  email:              'javier@path11.com',
  address:            'Avenida del Sauce 33, Cajón del Maipo, Chile',
  phone:              '09-9321-4567',
  contact_person:     'Sebastian',
  description:        %Q{Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam rutrum nisi orci. Donec mauris nisi, pharetra viverra tincidunt ac, adipiscing eget lacus. Etiam euismod vehicula laoreet. Ut neque eros, volutpat ac mollis sed, dapibus a arcu. Curabitur vitae purus sed odio volutpat porta. Vivamus mollis sollicitudin mi luctus rutrum. Donec mollis dolor risus, dictum luctus felis. Nam porttitor, ligula sit amet ullamcorper iaculis, justo mi condimentum odio, sed mollis lorem sapien eget felis. Vestibulum hendrerit vulputate erat non accumsan. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Curabitur malesuada arcu vel quam pretium at aliquam justo ornare. Praesent nec magna at mauris dapibus bibendum.},
  scheduled_tour_availability_policy: 'only_n_simultaneous_tours',
  scheduled_tour_availability_policy_parameters: {n: 1}.to_json
)
path11_tours.update_attribute(:encrypted_password, '$2a$10$BCw6543515ibbvckHv74ouxxeyYZ2556U77gHIGm.TEwcwN5.p4Om')

rock_climbing = Product.create(
  start_time:     Time.utc(2011, 10, 10, 9),
  name:           'Rock Climbing',
  description:    %Q{An undeniable curiosity evolves when Zion visitors travel the Canyon Scenic Drive and see small, colorful specks high on the towering walls. After careful viewing, onlookers eventually realize these specks are, unbelievably, human beings. Riding the shuttle, you may hear questions aloud: "How do they get up there? What are they holding on to? Where do they sleep if they spend the night? How do they go to the bathroom if they are up there for multiple days? What if they fall?\nWe can answer all of those questions for you and more. Explore our series of rock trips for the best fit for your group and abilities.},
  location:       'Zion Canyon in Cajón del Maipo',
  difficulty:     'Medium',
  min_capacity:   4,
  max_capacity:   10,
  duration:       "1.5",
  whats_included: %Q{We begin each session with basic climbing skill sets to ensure a really fun and educational day. The climbing areas we choose are magnificently located near Zion, with incredible vistas. Your day will include:\n- Climbing and hanging from ropes\n- Rock faces from 40 to 100 feet tall\n- Routes from super-easy to super-hard\n- Awesome mountain views\n- Shade and sun, as desired\n},
  what_to_bring:  %Q{We provide all necessary technical gear for your experience, but recommend you bring:\n- 2 quarts water/person\n- Lunch and snacks\n- Sunscreen\n- Warm layer and wind jacket\n- Light hiking pants or long shorts to protect your knees\n- Light hiking shoes or sneakers\n- Any type of camera},
  meeting_point:  'Zion Adventure Company at 36 Lion Blvd., across from the Quality Inn.',
  languages:      'English, Spanish, French, German, Portuguese',
  price_in_local_units: 40000
)
rock_climbing.update_attribute(:tour_operator, path11_tours)

ProductImage.create(product: rock_climbing, url: 'https://dl.dropbox.com/u/1130242/climbing1.jpg')
ProductImage.create(product: rock_climbing, url: 'https://dl.dropbox.com/u/1130242/climbing2.jpg')
ProductImage.create(product: rock_climbing, url: 'https://dl.dropbox.com/u/1130242/climbing3.jpg')
ProductImage.create(product: rock_climbing, url: 'https://dl.dropbox.com/u/1130242/climbing4.jpg')

(1..15).each { |number_of| ScheduledTour.create(product: rock_climbing, date: number_of.days.from_now) }

hiking  = Product.create(
  start_time:     Time.utc(2010, 10, 10, 9),
  name:           'Hiking the canyons',
  description:    %Q{Exploring the Narrows with a Zion Adventure Company guide allows you many opportunities to learn about the flora, fauna, geology, local history, and nuances of the Bottom-Up Day Hike route. The experience we offer is not about how far, but how much you get to see along the way, and the knowledge base we bring to the table. Certainly, most people can hike the Narrows as a self-guided explorer. Those who wish a higher level of interpretation and sometimes richer, more thorough, visit to this awesome locale, choose to hike with Zion Adventure Company leaders. NOTE: In order to hike north of Orderville Canyon, you must choose a self-guided Narrows Hike. No commercial guides can hike North of Orderville Canyon nor can we hike with you from Chamberlain's Ranch, in accordance with the Zion National Park General Management Plan Backcountry Compendium.},
  location:       'Zion Canyon in Cajón del Maipo',
  difficulty:     'Hard',
  min_capacity:   10,
  max_capacity:   20,
  duration:       "4.0",
  whats_included: %Q{7 days/week depending upon water flow rates.Warm water trips, usually late May through September depart at 8am.Cold Water trips, all other times of year depart about 9am. All trips leave from Zion Adventure Company at 36 Lion Blvd., across from the Quality Inn. Early reservations advised, yet walk-ins are possible. Reservations are required for this event in the off-season, November through April.},
  what_to_bring:  %Q{We provide all the necessary Narrows outfitting gear for your experience, but recommend you bring:\n-2 quarts of water/person + lunch/snacks for the day\n-Sunscreen and swimsuit in summer\n-Warm synthetic clothes any time of year\n-Camera\nWe will outfit depending upon the weather. Drysuits, drypants, and footwear packages, thermal layers, dry packs, and other accessories will be provided according to your guides suggestions. If you have signed up for a Warm Water event or Cold Water event, and the conditions are opposite as expected, we will charge/refund accordingly.},
  meeting_point:  'Zion Adventure Company at 36 Lion Blvd., across from the Quality Inn.',
  languages:      'English, Spanish, French',
  price_in_local_units: 125000
)
hiking.update_attribute(:tour_operator, path11_tours)

ProductImage.create(product: hiking, url: 'https://dl.dropbox.com/u/1130242/CanyonIntro.png')
ProductImage.create(product: hiking, url: 'https://dl.dropbox.com/u/1130242/CanyonTripsIntro.png')
ProductImage.create(product: hiking, url: 'https://dl.dropbox.com/u/1130242/FADIntro.png')
ProductImage.create(product: hiking, url: 'https://dl.dropbox.com/u/1130242/HFADIntro.png')

(1..12).each { |number_of| ScheduledTour.create(product: hiking, date: number_of.days.from_now) }


rafting = Product.create(
  start_time:     Time.utc(2010, 10, 10, 9),
  name:           'Rafting in the Zion waterfalls',
  description:    %Q{Canyoneering rarely makes headlines of any syndicated newspaper or the evening news unless some one, or many, are seriously injured or killed. We know 90% or more of all outdoor injuries or deaths can be prevented with solid risk management skills and keen leadership senses. This two-day rescue curriculum exposes students to the mental, physical, and emotional challenges and successes of expert canyoneers. Simple, effective, and expedient.},
  location:       'Zion River 20 Km away from Cajón del Maipo',
  difficulty:     'Hard',
  min_capacity:   8,
  max_capacity:   10,
  duration:       "2.0",
  whats_included: %Q{This is serious fun balanced with serious risk management, including technical manipulations to establish a base for participant confidence in both solo & group canyon rescue.},
  what_to_bring:  %Q{We can provide all the necessary technical gear, but recommend you have your own rappel device, helmet, harness, safety tether, and respective locking carabiners. The main emphasis of this course is to accomplish the most with the least.\nEach day of class, please bring:\n-2 quarts of water/person & food/snacks\n-Sunscreen and sun hat\n-Warm, synthetic clothing\n-Waterproof camera\n-Closed-toe shoes},
  meeting_point:  'Zion Adventure Company at 36 Lion Blvd., across from the Quality Inn.',
  languages:      'English, Spanish',
  price_in_local_units: 79000
)
rafting.update_attribute(:tour_operator, path11_tours)

ProductImage.create(product: rafting, url: 'https://dl.dropbox.com/u/1130242/rafting1.jpg')
ProductImage.create(product: rafting, url: 'https://dl.dropbox.com/u/1130242/rafting2.jpg')
ProductImage.create(product: rafting, url: 'https://dl.dropbox.com/u/1130242/rafting3.jpg')
ProductImage.create(product: rafting, url: 'https://dl.dropbox.com/u/1130242/rafting4.jpg')

(4..10).each { |number_of| ScheduledTour.create(product: rafting, date: number_of.days.from_now) }

SalesChannel.create!(name: 'Atrapalo', contact_name: 'Cristóbal', contact_email: 'cristobal@atrapalo.com')

Admin.create!(email: 'dan@kuotus.com', password: 'ku0tu5!', password_confirmation: 'ku0tu5!')


# TOUR OPERATOR 2
alberto = TourOperator.create!(
  email:                 'alberto@path11.com',
  password:              'arstarst',
  password_confirmation: 'arstarst',
  name:                  'Alberto Adventures',
  address:               'calle alberto SN',
  phone:                 '09-9321-2255',
  contact_person:        'Alberto',
  description:           %Q{Lorem ipsum dolor sit amet, consectetur adipiscing elit.},
  scheduled_tour_availability_policy: 'only_n_simultaneous_tours',
  scheduled_tour_availability_policy_parameters: {n: 2}.to_json
)

skying = Product.create(
  name:           'Skying',
  description:    %Q{skying, you know...},
  location:       'A mountain with Snow',
  difficulty:     'Easy',
  min_capacity:   2,
  max_capacity:   12,
  start_time:     Time.utc(2011, 10, 10, 9),
  duration:       "4.5",
  whats_included: %Q{An introductory class to skying},
  what_to_bring:  %Q{Warm clothes},
  meeting_point:  'Resort',
  languages:      'English, Spanish',
  price_in_local_units: 40000
)
skying.update_attribute(:tour_operator, alberto)
(1..30).each { |number_of| ScheduledTour.create(product: skying, date: number_of.days.from_now) }

snow_boarding = Product.create(
  name:           'Snow boarding',
  description:    %Q{snow boarding, you know...},
  location:       'A mountain with Snow',
  difficulty:     'Medium',
  min_capacity:   5,
  max_capacity:   10,
  start_time:     Time.utc(2011, 10, 10, 15),
  duration:       "3",
  whats_included: %Q{An introductory class to snow boarding},
  what_to_bring:  %Q{Warm clothes},
  meeting_point:  'Resort',
  languages:      'English, Spanish',
  price_in_local_units: 90000
)
snow_boarding.update_attribute(:tour_operator, alberto)
(1..30).each { |number_of| ScheduledTour.create(product: snow_boarding, date: number_of.days.from_now) }

snow_hiking = Product.create(
  name:           'Snow Hiking',
  description:    %Q{Hiking in the snow},
  location:       'A mountain with Snow',
  difficulty:     'Easy-Medium',
  min_capacity:   4,
  max_capacity:   20,
  start_time:     Time.utc(2011, 10, 10, 13),
  duration:       "3",
  whats_included: %Q{A lovely walk in thke Snow},
  what_to_bring:  %Q{Warm clothes},
  meeting_point:  'Resort',
  languages:      'English, Spanish',
  price_in_local_units: 20000
)
snow_hiking.update_attribute(:tour_operator, alberto)
(1..30).each { |number_of| ScheduledTour.create(product: snow_hiking, date: number_of.days.from_now) }

# TOUR OPERATOR 3
enrique = TourOperator.create!(
  email:                 'enrique@path11.com',
  password:              'arstarst',
  password_confirmation: 'arstarst',
  name:                  'Enrique Adventures',
  address:               'calle enrique SN',
  phone:                 '09-2222-4567',
  contact_person:        'Enrique',
  description:           %Q{Lorem ipsum dolor sit amet, consectetur adipiscing elit.},
  scheduled_tour_availability_policy: 'only_n_simultaneous_tours',
  scheduled_tour_availability_policy_parameters: {n: 3}.to_json
)

parachuting = Product.create(
  name:           'Parachuting',
  description:    %Q{Falling from the sky},
  location:       'The Sky',
  difficulty:     'Medium',
  min_capacity:   4,
  max_capacity:   6,
  start_time:     Time.utc(2011, 10, 10, 10),
  duration:       "4",
  whats_included: %Q{Everything necesary},
  what_to_bring:  %Q{Warm clothes},
  meeting_point:  'Airfield',
  languages:      'English, Spanish, German',
  price_in_local_units: 120000
)
parachuting.update_attribute(:tour_operator, enrique)
(1..30).each { |number_of| ScheduledTour.create(product: parachuting, date: number_of.days.from_now) }

base_jumping = Product.create(
  name:           'Base Jumping',
  description:    %Q{Falling from the top of a skyline},
  location:       'The City',
  difficulty:     'Hard',
  min_capacity:   2,
  max_capacity:   4,
  start_time:     Time.utc(2011, 10, 10, 12),
  duration:       "2",
  whats_included: %Q{Everything necesary},
  what_to_bring:  %Q{Warm clothes},
  meeting_point:  'Skyscraper',
  languages:      'English, Spanish, German',
  price_in_local_units: 200000
)
base_jumping.update_attribute(:tour_operator, enrique)
(1..30).each { |number_of| ScheduledTour.create(product: base_jumping, date: number_of.days.from_now) }

bungee_jumping = Product.create(
  name:           'Bungee Jumping',
  description:    %Q{Falling from the top of a bridge},
  location:       'The Bridge',
  difficulty:     'Hard',
  min_capacity:   2,
  max_capacity:   15,
  start_time:     Time.utc(2011, 10, 10, 11),
  duration:       "3",
  whats_included: %Q{Everything necesary},
  what_to_bring:  %Q{Courage. A priest},
  meeting_point:  'Bridge',
  languages:      'English, Spanish, German',
  price_in_local_units: 180000
)
bungee_jumping.update_attribute(:tour_operator, enrique)
(1..30).each { |number_of| ScheduledTour.create(product: bungee_jumping, date: number_of.days.from_now) }

