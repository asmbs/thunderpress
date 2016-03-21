<?php

namespace ASMBS\Thunderpress;

use Composer\Script\Event;


/**
 * Configuration helper
 * @author  Kyle Tucker <kyleatucker@gmail.com>
 */
class ScriptHandler
{
    /** @var  string  The name of the dotenv file that gets loaded. */
    public static $envFile = '.env';

    /** @var  string  The name of the distributed dotenv template. */
    public static $distFile = '.env.dist';

    /** @var  array  Salt config keys. */
    public static $saltKeys = [
        'AUTH_KEY',
        'SECURE_AUTH_KEY',
        'LOGGED_IN_KEY',
        'NONCE_KEY',
        'AUTH_SALT',
        'SECURE_AUTH_SALT',
        'LOGGED_IN_SALT',
        'NONCE_SALT',
    ];

    /**
     * Generate auth salts and add them to the .env file.
     *
     * @param   Event  $event
     * @return  int
     */
    public static function addSalts(Event $event)
    {
        $composer = $event->getComposer();
        $io = $event->getIO();

        // Determine whether to proceed.
        if (!$io->isInteractive()) {
            $generate = $composer->getConfig()->get('generate-salts');
        } else {
            $generate = $io->askConfirmation(
                '<question>Generate salts and update .env file?</question> [<comment>Y|n</comment>]',
                true
            );
        }

        // Stop executing if requested
        if (!$generate) {
            $io->write('Salts not generated.');

            return 1;
        }

        // Get paths
        $root = dirname(dirname(dirname(__DIR__)));
        $envFile = $root .'/'. self::$envFile;
        $distFile = $root .'/'. self::$distFile;

        // Check if the .env file exists -- if not, copy the dist file
        if (!file_exists($envFile)) {
            if (!copy($distFile, $envFile)) {
                $io->write('<error>Unable to copy the distributed .env file</error>');

                return 1;
            }

            $io->write('<info>Copied <fg=white>'. self::$envFile .'</> contents to <fg=white>'. self::$distFile .'</>');
        }

        // Read the file
        $contents = file_get_contents($envFile);
        // Make sure it has a newline at the end
        if ($contents[strlen($contents) - 1] !== "\n") {
            $contents .= "\n";
        }

        foreach (self::$saltKeys as $key) {
            // Generate a salt
            $salt = self::generateSalt();
            $string = sprintf("%s='%s'", $key, $salt);

            if (strpos($contents, $key) !== false) {
                // If the key exists in the file, overwrite it
                $contents = preg_replace("/${key} *= *'.*'/", $string, $contents);
            } else {
                // Otherwise append it
                $contents .= $string ."\n";
            }
        }

        // Rewrite the file
        if (!file_put_contents($envFile, $contents, LOCK_EX)) {
            $io->write('<error>Unable to write changes to the .env file</error>');

            return 1;
        }
        
        $io->write('<info>Salts have been written to your .env file</info>');

        return 0;
    }

    /**
     * Generate a random salt.
     *
     * @param   int  $length
     * @return  string
     */
    protected static function generateSalt($length = 64)
    {
        $chars  = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        $chars .= '!@#$%^&*()';
        $chars .= '-_ []{}<>~`+=,.;:/?|';

        $salt = '';
        for ($i = 0; $i < $length; $i++) {
            $salt .= substr($chars, mt_rand(0, strlen($chars)), 1);
        }

        return $salt;
    }
}
