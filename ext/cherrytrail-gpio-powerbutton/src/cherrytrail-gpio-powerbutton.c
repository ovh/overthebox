/* This code is an hack to make the power button
 * on cherrytrail work with older kernels..
 * It's based on the work of Sébastien Duponcheel:
 * https://github.com/sduponch/cherrytrail-gpio-powerbutton.git
 * */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>
#include <linux/gpio.h>
#include <linux/interrupt.h>
#include <linux/input.h>
#include <linux/acpi.h>

MODULE_LICENSE("GPL");
MODULE_VERSION("0.1");

#define CHT_PWRBTN_GPIO 381
#define CHT_PWRBTN_NAME "cherrytrail-gpio-powerbutton"

static irqreturn_t
cht_pwrbtn_irq(int irq, void *data)
{
	struct input_dev *input = (struct input_dev *)data;

	input_event(input, EV_KEY, KEY_POWER, !gpio_get_value(CHT_PWRBTN_GPIO));
	input_sync(input);

	return IRQ_HANDLED;
}

static int
cht_pwrbtn_probe(struct platform_device *pdev)
{
	int ret;
	struct device *dev = &pdev->dev;
	struct input_dev *input;

	ret = devm_gpio_request_one(dev, CHT_PWRBTN_GPIO, GPIOF_DIR_IN | GPIOF_ACTIVE_LOW, CHT_PWRBTN_NAME);

	if (ret) {
		dev_err(dev, "Failed to request GPIO %d, error %d\n", CHT_PWRBTN_GPIO, ret);
		return ret;
	}

	input = devm_input_allocate_device(dev);

	if (!input) {
		dev_err(dev, "Failed to allocate input device\n");
		return -ENOMEM;
	}

	input->name = CHT_PWRBTN_NAME;
	input->evbit[0] = BIT_MASK(EV_KEY);
	input_set_capability(input, EV_KEY, KEY_POWER);

	ret = gpio_to_irq(CHT_PWRBTN_GPIO);

	if (ret < 0) {
		dev_err(dev, "Unable to get irq number for GPIO %d, error %d\n", CHT_PWRBTN_GPIO, ret);
		return ret;
	}

	ret = devm_request_irq(dev, ret, cht_pwrbtn_irq, (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_RISING), CHT_PWRBTN_NAME, input);

	if (ret) {
		dev_err(dev, "Unable to request irq, error: %d\n", ret);
		return ret;
	}

	ret = input_register_device(input);

	if (ret) {
		dev_err(dev, "Unable to register input device, error: %d\n", ret);
		return ret;
	}

	platform_set_drvdata(pdev, input);
	device_init_wakeup(&pdev->dev, 1);

	dev_info(dev, "Driver successfully loaded");
	return 0;
}

static const struct acpi_device_id
cht_pwrbtn_acpi_match[] = {
	{ "INT33FF" },
	{ }
};
MODULE_DEVICE_TABLE(acpi, cht_pwrbtn_acpi_match);

static struct platform_driver
cht_pwrbtn_driver = {
	.probe = cht_pwrbtn_probe,
	.driver = {
		.name = CHT_PWRBTN_NAME,
		.acpi_match_table = cht_pwrbtn_acpi_match,
	},
};

static int __init
cht_pwrbtn_init(void)
{
	return platform_driver_register(&cht_pwrbtn_driver);
}

static void __exit
cht_pwrbtn_exit(void)
{
	platform_driver_unregister(&cht_pwrbtn_driver);
}

module_init(cht_pwrbtn_init);
module_exit(cht_pwrbtn_exit);
